port module StoryVotes exposing (..)

import Browser
import Data.Category as Category exposing (Category)
import Data.Votes as Votes exposing (VerifiedVote, VotesResponse)
import Element exposing (..)
import Element.Attributes exposing (..)
import Helpers exposing (onClickStopPropagation)
import Html exposing (Html)
import Html.Attributes
import List.Extra
import Locale.Languages exposing (Language)
import Locale.Locale as Locale exposing (translate)
import Locale.Words as Words exposing (LocaleKey)
import RemoteData exposing (..)
import Stylesheet exposing (..)


type alias Model =
    { url : String, title : String, isExtensionPopup : Bool, votes : WebData VotesResponse, language : Language }


type alias Flags =
    { url : String, title : String, isExtensionPopup : Bool, languages : List String }


type Msg
    = OpenFlagPopup
    | VotesResponse (WebData VotesResponse)
    | AddVote { categoryId : Int }


port openFlagPopup : { url : String, title : String } -> Cmd msg


port addVote : ({ categoryId : Int } -> msg) -> Sub msg


main : Program Flags Model Msg
main =
    Browser.element
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


init : Flags -> ( Model, Cmd Msg )
init flags =
    ( { url = flags.url
      , title = flags.title
      , isExtensionPopup = flags.isExtensionPopup
      , votes = NotAsked
      , language = Locale.fromCodeArray flags.languages
      }
    , Votes.getVotes VotesResponse flags.url flags.title
    )


subscriptions : Model -> Sub Msg
subscriptions model =
    addVote AddVote


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        OpenFlagPopup ->
            ( model, openFlagPopup { url = model.url, title = model.title } )

        VotesResponse response ->
            ( { model | votes = response }, Cmd.none )

        AddVote { categoryId } ->
            let
                category =
                    Category.fromId categoryId

                isCategory voteCount =
                    voteCount.category == category

                peopleVotes =
                    case model.votes of
                        Success votes ->
                            if List.Extra.find isCategory votes.people.content == Nothing then
                                { category = category, count = 1 } :: votes.people.content

                            else
                                List.Extra.updateIf isCategory
                                    (\voteCount -> { voteCount | count = voteCount.count + 1 })
                                    votes.people.content

                        _ ->
                            [ { category = category, count = 1 } ]

                updatedVotes =
                    model.votes
                        |> RemoteData.map
                            (\votes ->
                                let
                                    people =
                                        votes.people
                                in
                                { votes | people = { people | content = peopleVotes } }
                            )
                        |> RemoteData.withDefault
                            { domain = Nothing
                            , robot =
                                { fake_news = 0
                                , extremely_biased = 0
                                , clickbait = 0
                                }
                            , people = { content = peopleVotes, title = { clickbait = False, count = 0 } }
                            }
            in
            ( { model | votes = Success updatedVotes }, Cmd.none )


view : Model -> Html Msg
view model =
    Html.div
        (if model.isExtensionPopup then
            [ Html.Attributes.style "float" "right" ]

         else
            [ Html.Attributes.style "position" "absolute"
            , Html.Attributes.style "right" "0"
            , Html.Attributes.style "z-index" "1"
            ]
        )
        [ Element.layout stylesheet (flagButtonAndVotes model)
        ]


flagButtonAndVotes : Model -> Element Classes variation Msg
flagButtonAndVotes model =
    let
        translate =
            Locale.translate model.language

        viewVerifiedVote vote =
            viewVote model (Category.toEmoji vote.category) "" vote.category (translate Words.Verified)

        isValidUrl =
            String.startsWith "http"
    in
    if isValidUrl model.url then
        column General
            [ spacing 5, padding 5, minWidth (px 130) ]
            [ flagButton model
            , case model.votes of
                Success votes ->
                    case votes.domain of
                        Just vote ->
                            viewVerifiedVote vote

                        Nothing ->
                            viewVotes model votes

                Failure _ ->
                    el VoteCountItem [ padding 6 ] (text <| translate Words.LoadingError)

                _ ->
                    empty
            ]

    else
        el General [ padding 5 ] (text <| translate Words.InvalidUrlError ++ model.url)


flagButton : Model -> Element Classes variation Msg
flagButton model =
    button Button
        [ padding 4, onClickStopPropagation OpenFlagPopup ]
        (text <| Locale.translate model.language Words.FlagButton)


viewVotes : Model -> VotesResponse -> Element Classes variation Msg
viewVotes model votes =
    let
        peopleVotes =
            Votes.joinClickbaitCategory votes.people

        viewRobotVote ( chanceText, category ) =
            viewVote model "\u{1F916}" (Locale.translate model.language chanceText) category ""

        viewPeopleVote vote =
            viewVote model (Category.toEmoji vote.category) (String.fromInt vote.count) vote.category ""

        robotPredictions =
            Votes.predictionsToText votes.robot
    in
    column NoStyle [ spacing 5 ] (List.map viewRobotVote robotPredictions ++ List.map viewPeopleVote peopleVotes)


viewVote : Model -> String -> String -> Category -> String -> Element Classes variation msg
viewVote model icon preText category postText =
    row VoteCountItem
        [ padding 6, spacing 5, height (px 26) ]
        [ el VoteEmoji [ moveUp 4 ] (text icon)
        , text <|
            preText
                ++ " "
                ++ (Category.toName category
                        |> translate model.language
                        |> String.toLower
                   )
        , text postText
        ]
