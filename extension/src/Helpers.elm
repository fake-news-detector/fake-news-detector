module Helpers exposing (..)

import Element exposing (..)
import Element.Events exposing (..)
import Http exposing (Error(..))
import Json.Decode
import Locale.Languages exposing (Language)
import Locale.Locale as Locale exposing (translate)
import Locale.Words as Words exposing (LocaleKey)


onClickStopPropagation : msg -> Element.Attribute variation msg
onClickStopPropagation message =
    Element.Events.custom "click" (Json.Decode.succeed { message = message, stopPropagation = True, preventDefault = True })


humanizeError : Language -> Http.Error -> String
humanizeError language error =
    case error of
        Timeout ->
            Locale.translate language Words.TimeoutError

        NetworkError ->
            Locale.translate language Words.NetworkError

        BadBody err ->
            "BadBody " ++ err

        BadUrl err ->
            "BadUrl " ++ err

        BadStatus code ->
            "BadStatus " ++ String.fromInt code
