module Helpers exposing (..)

import Element exposing (..)
import Element.Events exposing (..)
import Http exposing (Error(..))
import Json.Decode
import Locale.Languages exposing (Language)
import Locale.Locale as Locale exposing (translate)
import Locale.Words as Words exposing (LocaleKey)


onClickStopPropagation : msg -> Element.Attribute variation msg
onClickStopPropagation msg =
    onWithOptions "click"
        { defaultOptions | stopPropagation = True, preventDefault = True }
        (Json.Decode.succeed msg)


humanizeError : Language -> Http.Error -> String
humanizeError language error =
    case error of
        BadStatus data ->
            data.body

        Timeout ->
            Locale.translate language Words.TimeoutError

        NetworkError ->
            Locale.translate language Words.NetworkError

        BadPayload _ data ->
            data.body

        BadUrl error ->
            error
