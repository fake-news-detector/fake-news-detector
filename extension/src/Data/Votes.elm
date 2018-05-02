module Data.Votes exposing (..)

import Data.Category as Category exposing (..)
import Http exposing (encodeUri)
import Json.Decode exposing (Decoder, bool, float, int, list, nullable)
import Json.Decode.Pipeline exposing (decode, required)
import Json.Encode
import Locale.Words as Words


type alias PeopleVotes =
    { content : List PeopleContentVote
    , title : PeopleTitleVotes
    }


type alias PeopleContentVote =
    { category : Category, count : Int }


type alias PeopleTitleVotes =
    { clickbait : Bool, count : Int }


type alias RobotPredictions =
    { fake_news : Float, extremely_biased : Float, clickbait : Float }


type alias VerifiedVote =
    { category : Category }


type alias VotesResponse =
    { domain : Maybe VerifiedVote
    , robot : RobotPredictions
    , people : PeopleVotes
    }


type YesNoIdk
    = Yes
    | No
    | DontKnow


type alias NewVote =
    { uuid : String
    , url : String
    , title : String
    , category : Category
    , clickbaitTitle : YesNoIdk
    }


encodeYesNoIdk : YesNoIdk -> Json.Encode.Value
encodeYesNoIdk val =
    case val of
        Yes ->
            Json.Encode.bool True

        No ->
            Json.Encode.bool False

        DontKnow ->
            Json.Encode.null


decodeVotesResponse : Decoder VotesResponse
decodeVotesResponse =
    let
        decodeCategory =
            required "category_id" (Json.Decode.map Category.fromId int)

        decodeDomainCategory =
            decode VerifiedVote
                |> decodeCategory

        decodeRobotPredictions =
            decode RobotPredictions
                |> required "fake_news" float
                |> required "extremely_biased" float
                |> required "clickbait" float

        decodeContentPeopleVote =
            decode PeopleContentVote
                |> decodeCategory
                |> required "count" int

        decodePeopleTitleVotes =
            decode PeopleTitleVotes
                |> required "clickbait" bool
                |> required "count" int

        decodePeopleVotes =
            decode PeopleVotes
                |> required "content" (list decodeContentPeopleVote)
                |> required "title" decodePeopleTitleVotes
    in
    decode VotesResponse
        |> required "domain" (nullable decodeDomainCategory)
        |> required "robot" decodeRobotPredictions
        |> required "people" decodePeopleVotes


getVotes : String -> String -> Http.Request VotesResponse
getVotes url title =
    Http.get ("https://api.fakenewsdetector.org/votes?url=" ++ encodeUri url ++ "&title=" ++ encodeUri title) decodeVotesResponse


encodeNewVote : NewVote -> Json.Encode.Value
encodeNewVote { uuid, url, title, category, clickbaitTitle } =
    Json.Encode.object
        [ ( "uuid", Json.Encode.string uuid )
        , ( "url", Json.Encode.string url )
        , ( "title", Json.Encode.string title )
        , ( "category_id", Json.Encode.int (Category.toId category) )
        , ( "clickbait_title", encodeYesNoIdk clickbaitTitle )
        ]


postVote : NewVote -> Http.Request ()
postVote newVote =
    Http.post "https://api.fakenewsdetector.org/vote"
        (Http.jsonBody (encodeNewVote newVote))
        (Json.Decode.succeed ())


chanceToText : number -> Words.LocaleKey
chanceToText chance =
    let
        rebalancedChance =
            (chance * 100 - 50) * 2
    in
    if rebalancedChance >= 66 then
        Words.AlmostCertain
    else if rebalancedChance >= 33 then
        Words.LooksALotLike
    else
        Words.LooksLike


predictionsToText : RobotPredictions -> List ( Words.LocaleKey, Category )
predictionsToText predictions =
    [ ( FakeNews, predictions.fake_news )
    , ( ExtremelyBiased, predictions.extremely_biased )
    , ( Clickbait, predictions.clickbait )
    ]
        |> List.filter (\prediction -> Tuple.second prediction > 0.6)
        |> List.sortBy (\( _, chance ) -> chance * -1)
        |> List.map (\( word, chance ) -> ( chanceToText chance, word ))


joinClickbaitCategory : PeopleVotes -> List PeopleContentVote
joinClickbaitCategory peopleVotes =
    let
        allCategories =
            if peopleVotes.title.clickbait then
                peopleVotes.content ++ [ { category = Clickbait, count = peopleVotes.title.count } ]
            else
                peopleVotes.content
    in
    allCategories
        |> List.sortBy (\vote -> vote.count * -1)
