module Router exposing (..)

import Http exposing (encodeUri)
import Navigation exposing (Location)
import UrlParser exposing (..)


type Route
    = IndexRoute
    | SearchRoute String


matchers : Parser (Route -> a) a
matchers =
    oneOf
        [ map IndexRoute top
        , map SearchRoute (s "search" </> string)
        ]


parseLocation : Location -> Route
parseLocation location =
    case parseHash matchers location of
        Just route ->
            route

        Nothing ->
            IndexRoute


toPath : Route -> String
toPath route =
    case route of
        IndexRoute ->
            "#"

        SearchRoute q ->
            "#search/" ++ encodeUri q
