module FlagLink exposing (..)

import Data.Category as Category exposing (Category(..))
import Data.Votes as Votes exposing (YesNoIdk(..))
import Element exposing (..)
import Element.Attributes exposing (..)
import Element.Events exposing (..)
import Element.Input as Input exposing (hiddenLabel, placeholder)
import Helpers exposing (humanizeError, onClickStopPropagation)
import Http
import Locale.Languages exposing (Language(..))
import Locale.Locale as Locale exposing (translate)
import Locale.Words as Words
import RemoteData exposing (..)
import Stylesheet exposing (..)


type alias Model =
    { state : FlaggingState
    , selectedCategory : Maybe Category
    , selectedClickbaitTitle : Maybe YesNoIdk
    , submitResponse : WebData ()
    }


type FlaggingState
    = Opened
    | Closed
    | Flagged


init : Model
init =
    { state = Closed
    , selectedCategory = Nothing
    , selectedClickbaitTitle = Nothing
    , submitResponse = NotAsked
    }


type Msg
    = OpenFlagForm
    | CloseFlagForm
    | SelectCategory Category
    | SelectClickbaitTitle YesNoIdk
    | SubmitFlag String String Language
    | SubmitResponse (WebData ())


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        OpenFlagForm ->
            ( { model | state = Opened }, Cmd.none )

        CloseFlagForm ->
            ( init, Cmd.none )

        SelectCategory category ->
            ( { model | selectedCategory = Just category }, Cmd.none )

        SelectClickbaitTitle isClickbaitTitle ->
            ( { model | selectedClickbaitTitle = Just isClickbaitTitle }, Cmd.none )

        SubmitFlag uuid url language ->
            case ( decodeQuery url, model.selectedCategory, model.selectedClickbaitTitle ) of
                ( Url url, Just selectedCategory, Just selectedClickbaitTitle ) ->
                    ( { model | submitResponse = RemoteData.Loading }
                    , Votes.postVote
                        { uuid = uuid
                        , url = url
                        , title = ""
                        , category = selectedCategory
                        , clickbaitTitle = selectedClickbaitTitle
                        }
                        |> RemoteData.sendRequest
                        |> Cmd.map SubmitResponse
                    )

                ( Content content, Just selectedCategory, _ ) ->
                    ( { model | submitResponse = RemoteData.Loading }
                    , Votes.postVoteByContent uuid content selectedCategory
                        |> RemoteData.sendRequest
                        |> Cmd.map SubmitResponse
                    )

                _ ->
                    -- TODO: Remove this workaround, use elm-form for validations instead
                    ( { model
                        | submitResponse =
                            Failure (Http.BadUrl <| Locale.translate language Words.FillAllFields)
                      }
                    , Cmd.none
                    )

        SubmitResponse response ->
            if isSuccess response then
                ( { model | state = Flagged }, Cmd.none )
            else
                ( { model | submitResponse = response }, Cmd.none )


flagLink : String -> String -> Language -> Model -> Element Classes variation Msg
flagLink uuid url language model =
    column NoStyle
        []
        [ bold <| translate language Words.HelpRobinho
        , case model.state of
            Opened ->
                flagForm uuid url language model

            Closed ->
                paragraph NoStyle
                    [ verticalCenter ]
                    [ el NoStyle [ paddingRight 5 ] (text <| translate language Words.HelpImproveResult)
                    , flagButton language model
                    ]

            Flagged ->
                text (translate language Words.ContentFlagged)
        ]


flagButton : Language -> Model -> Element Classes variation Msg
flagButton language model =
    button Button
        [ padding 4, onClick OpenFlagForm ]
        (text <| Locale.translate language Words.FlagButton)


flagForm : String -> String -> Language -> Model -> Element Classes variation Msg
flagForm uuid url language model =
    let
        translate =
            Locale.translate language
    in
    node "form" <|
        column NoStyle
            [ spacing 15, paddingTop 10 ]
            [ Input.radio NoStyle
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
            , case decodeQuery url of
                Url url ->
                    column NoStyle
                        []
                        [ Element.column NoStyle
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
                        ]

                _ ->
                    empty
            , case model.submitResponse of
                Failure err ->
                    paragraph ErrorMessage [ padding 6 ] [ text (humanizeError language err) ]

                _ ->
                    empty
            , el NoStyle
                []
                (button BlueButton
                    [ padding 5, onClickStopPropagation (SubmitFlag uuid url language) ]
                    (if isLoading model.submitResponse then
                        text <| translate Words.Loading
                     else
                        text <| translate Words.FlagSubmitButton
                    )
                )
            ]


flagChoice : Category -> String -> String -> Input.Choice Category Classes variation msg
flagChoice category title description =
    Input.choice category <|
        Element.column NoStyle
            [ spacing 12 ]
            [ bold title
            , paragraph NoStyle [] [ text description ]
            ]


type Query
    = Url String
    | Content String
    | Invalid
    | Empty


decodeQuery : String -> Query
decodeQuery query =
    if String.isEmpty query then
        Empty
    else if String.startsWith "http" query then
        Url query
    else if String.length query >= 20 then
        Content query
    else
        Invalid
