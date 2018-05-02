module Stylesheet exposing (..)

import Color exposing (..)
import Style exposing (..)
import Style.Border as Border
import Style.Color as Color
import Style.Font as Font


type Styles
    = None
    | General
    | Logo
    | Navigation
    | Title


stylesheet : StyleSheet Styles variation
stylesheet =
    Style.styleSheet
        [ style None []
        , style General
            [ -- source: https://www.smashingmagazine.com/2015/11/using-system-ui-fonts-practical-guide/
              Font.typeface (List.map Font.font [ "-apple-system", "BlinkMacSystemFont", "Segoe UI", "Roboto", "Oxygen", "Ubuntu", "sans-serif" ])
            , Font.size 14
            ]
        , style Logo
            [ Font.size 18
            ]
        , style Navigation
            [ Color.background black
            , Color.text white
            ]
        , style Title
            [ Font.size 32
            ]
        ]
