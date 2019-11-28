module Locale.Locale exposing
    ( fromCodeArray
    , toCodeArray
    , translate
    )

import Locale.English as English
import Locale.Languages exposing (Language(..))
import Locale.Portuguese as Portuguese
import Locale.Spanish as Spanish
import Locale.Words exposing (LocaleKey)


fromCodeArray : List String -> Language
fromCodeArray codes =
    extractPreferredLanguage codes


toCodeArray : Language -> List String
toCodeArray language =
    case language of
        Portuguese ->
            [ "pt" ]

        English ->
            [ "en" ]

        Spanish ->
            [ "es" ]


translate : Language -> LocaleKey -> String
translate language localeValue =
    case language of
        English ->
            English.translate localeValue

        Portuguese ->
            Portuguese.translate localeValue

        Spanish ->
            Spanish.translate localeValue


extractPreferredLanguage : List String -> Language
extractPreferredLanguage codes =
    let
        -- Only the first 2 chars matters (e.g. "pt-BR" -> "pt")
        convertedCodes =
            List.map
                (String.left 2)
                codes
    in
    if List.member "pt" convertedCodes then
        Portuguese

    else
        case List.head convertedCodes of
            Just "es" ->
                Spanish

            _ ->
                English
