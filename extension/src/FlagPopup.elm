port module FlagPopup exposing (..)

import Data.Category as Category exposing (Category(..))
import Data.Votes as Votes exposing (YesNoIdk(..))
import Element exposing (..)
import Element.Attributes exposing (..)
import Element.Events exposing (..)
import Element.Input as Input
import Helpers exposing (humanizeError, onClickStopPropagation)
import Html exposing (Html)
import Html.Attributes
import Http
import Keyboard
import Locale.Languages exposing (Language)
import Locale.Locale as Locale exposing (translate)
import Locale.Words as Words exposing (LocaleKey)
import RemoteData exposing (..)
import Stylesheet exposing (..)


type alias Model =
    { isOpen : Bool
    , uuid : String
    , isExtensionPopup : Bool
    , url : String
    , title : String
    , selectedCategory : Maybe Category
    , selectedClickbaitTitle : Maybe YesNoIdk
    , submitResponse : WebData ()
    , language : Language
    }


init : Flags -> ( Model, Cmd Msg )
init flags =
    ( { isOpen = False
      , uuid = flags.uuid
      , isExtensionPopup = flags.isExtensionPopup
      , url = ""
      , title = ""
      , selectedCategory = Nothing
      , selectedClickbaitTitle = Nothing
      , submitResponse = NotAsked
      , language = Locale.fromCodeArray flags.languages
      }
    , Cmd.none
    )


port broadcastVote : { url : String, categoryId : Int } -> Cmd msg


port openFlagPopup : ({ url : String, title : String } -> msg) -> Sub msg


type Msg
    = OpenPopup { url : String, title : String }
    | ClosePopup
    | SelectCategory Category
    | SelectClickbaitTitle YesNoIdk
    | SubmitFlag
    | SubmitResponse (WebData ())
    | KeyboardDown Keyboard.KeyCode


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        OpenPopup { url, title } ->
            ( { model | isOpen = True, url = url, title = title }, Cmd.none )

        ClosePopup ->
            init
                { uuid = model.uuid
                , isExtensionPopup = model.isExtensionPopup
                , languages = Locale.toCodeArray model.language
                }

        SelectCategory category ->
            ( { model | selectedCategory = Just category }, Cmd.none )

        SelectClickbaitTitle isClickbaitTitle ->
            ( { model | selectedClickbaitTitle = Just isClickbaitTitle }, Cmd.none )

        SubmitFlag ->
            case ( model.selectedCategory, model.selectedClickbaitTitle ) of
                ( Just selectedCategory, Just selectedClickbaitTitle ) ->
                    ( { model | submitResponse = RemoteData.Loading }
                    , Votes.postVote
                        { uuid = model.uuid
                        , url = model.url
                        , title = model.title
                        , category = selectedCategory
                        , clickbaitTitle = selectedClickbaitTitle
                        }
                        |> RemoteData.sendRequest
                        |> Cmd.map SubmitResponse
                    )

                _ ->
                    -- TODO: Remove this workaround, use elm-form for validations instead
                    ( { model
                        | submitResponse =
                            Failure (Http.BadUrl <| Locale.translate model.language Words.FillAllFields)
                      }
                    , Cmd.none
                    )

        SubmitResponse response ->
            if isSuccess response then
                ( Tuple.first (update ClosePopup model)
                , broadcastVote
                    { url = model.url
                    , categoryId =
                        model.selectedCategory
                            |> Maybe.map Category.toId
                            |> Maybe.withDefault 0
                    }
                )
            else
                ( { model | submitResponse = response }, Cmd.none )

        KeyboardDown code ->
            -- 27 is the escape keycode
            if code == 27 then
                update ClosePopup model
            else
                ( model, Cmd.none )


type alias Flags =
    { uuid : String, isExtensionPopup : Bool, languages : List String }


main : Program Flags Model Msg
main =
    Html.programWithFlags
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ openFlagPopup OpenPopup
        , Keyboard.downs KeyboardDown
        ]


view : Model -> Html Msg
view model =
    Html.div
        [ Html.Attributes.style
            [ ( "float", "right" ) ]
        ]
        [ Element.layout stylesheet (popup model)
        ]


popup : Model -> Element Classes variation Msg
popup model =
    when model.isOpen
        (if model.isExtensionPopup then
            modalContents model
         else
            row NoStyle
                []
                [ screen <|
                    el Overlay
                        [ width (percent 100)
                        , height (percent 100)
                        , onClick ClosePopup
                        ]
                        empty
                , modal NoStyle
                    [ center
                    , verticalCenter
                    ]
                    (modalContents model)
                ]
        )


modalContents : Model -> Element Classes variation Msg
modalContents model =
    let
        translate =
            Locale.translate model.language
    in
    el Popup
        [ padding 20, width (px 450) ]
        (column General
            [ spacing 15 ]
            [ h1 Title [] (text <| translate Words.FlagContent)
            , flagForm model
            ]
            |> onRight [ button CloseButton [ onClick ClosePopup, padding 8, moveLeft 8, moveUp 20 ] (text "x") ]
        )


flagForm : Model -> Element Classes variation Msg
flagForm model =
    let
        translate =
            Locale.translate model.language
    in
    node "form" <|
        column NoStyle
            [ spacing 15 ]
            [ paragraph NoStyle [] [ bold <| translate Words.FlagQuestion ]
            , Input.radio NoStyle
                [ spacing 15
                ]
                { onChange = SelectCategory
                , selected = model.selectedCategory
                , label = Input.labelAbove empty
                , options = []
                , choices =
                    [ flagChoice Legitimate
                        (translate Words.Legitimate)
                        (translate Words.LegitimateDescription)
                    , flagChoice FakeNews
                        (translate Words.FakeNews)
                        (translate Words.FakeNewsDescription)
                    , flagChoice ExtremelyBiased
                        (translate Words.ExtremelyBiased)
                        (translate Words.ExtremelyBiasedDescription)
                    , flagChoice Satire
                        (translate Words.Satire)
                        (translate Words.SatireDescription)
                    , flagChoice NotNews
                        (translate Words.NotNews)
                        (translate Words.NotNewsDescription)
                    ]
                }
            , Element.column NoStyle
                [ paddingTop 15, spacing 4 ]
                [ bold <| translate Words.ClickbaitQuestion
                , paragraph NoStyle [] [ text <| translate Words.ClickbaitDescription ]
                ]
            , Input.radioRow NoStyle
                [ spacing 15
                , paddingTop 4
                ]
                { onChange = SelectClickbaitTitle
                , selected = model.selectedClickbaitTitle
                , label = Input.labelAbove empty
                , options = []
                , choices =
                    [ Input.choice Yes (text <| translate Words.Yes)
                    , Input.choice No (text <| translate Words.No)
                    , Input.choice DontKnow (text <| translate Words.DontKnow)
                    ]
                }
            , case model.submitResponse of
                Failure err ->
                    paragraph ErrorMessage [ padding 6 ] [ text (humanizeError model.language err) ]

                _ ->
                    empty
            , row NoStyle
                [ width fill, spread, verticalCenter ]
                [ italic ("link: " ++ model.url)
                , button BlueButton
                    [ padding 5, onClickStopPropagation SubmitFlag ]
                    (if isLoading model.submitResponse then
                        text <| translate Words.Loading
                     else
                        text <| translate Words.FlagSubmitButton
                    )
                ]
            ]


flagChoice : Category -> String -> String -> Input.Choice Category Classes variation msg
flagChoice category title description =
    Input.choice category <|
        Element.column NoStyle
            [ spacing 12 ]
            [ bold title
            , paragraph NoStyle [] [ text description ]
            ]
