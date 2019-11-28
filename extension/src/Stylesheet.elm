module Stylesheet exposing (..)

import Style exposing (hover, pseudo, rgba, style, styleSheet)
import Style.Border as Border
import Style.Color as Color
import Style.Font as Font
import Style.Shadow as Shadow


type Classes
    = NoStyle
    | General
    | Button
    | BlueButton
    | VoteCountItem
    | Overlay
    | Popup
    | Title
    | CloseButton
    | VoteEmoji
    | ErrorMessage


rgb a b c =
    Style.rgb (a / 255) (b / 255) (c / 255)


white =
    rgb 255 255 255


darkGrey =
    rgb 186 189 182


grey =
    rgb 211 215 207


stylesheet : Style.StyleSheet Classes variation
stylesheet =
    styleSheet
        [ style General
            [ -- source: https://www.smashingmagazine.com/2015/11/using-system-ui-fonts-practical-guide/
              Font.typeface (List.map Font.font [ "-apple-system", "BlinkMacSystemFont", "Segoe UI", "Roboto", "Oxygen", "Ubuntu", "sans-serif" ])
            , Font.size 12
            ]
        , style Button
            [ Color.text (rgb 75 79 86)
            , Border.all 1
            , Color.background (rgb 246 247 249)
            , Color.border (rgb 206 208 212)
            , hover
                [ Color.background (rgb 233 235 238)
                , Color.border (rgb 75 79 86)
                ]
            ]
        , style BlueButton
            [ Color.text white
            , Color.background (rgb 66 103 178)
            , Border.rounded 2
            , pseudo "active"
                [ Color.background (rgb 46 83 158)
                ]
            ]
        , style VoteCountItem
            [ Color.text white
            , Color.background (rgba 0 0 0 0.6)
            , Border.rounded 6
            ]
        , style Overlay
            [ Color.background (rgba 0 0 0 0.2)
            ]
        , style Popup
            [ Color.background white
            , Border.all 1
            , Border.rounded 3
            , Color.border (rgb 229 229 229)
            , Shadow.box
                { offset = ( 0, 0 )
                , size = 2
                , blur = 26
                , color = rgba 0 0 0 0.3
                }
            ]
        , style Title
            [ Font.size 24
            ]
        , style CloseButton
            [ Font.size 18
            , Color.text grey
            , Font.weight 300
            , Color.background white
            , hover
                [ Color.text darkGrey
                ]
            ]
        , style VoteEmoji
            [ Font.size 20
            ]
        , style ErrorMessage
            [ Color.border (rgb 245 198 203)
            , Color.background (rgb 248 215 218)
            , Color.text (rgb 114 28 36)
            , Border.all 1
            , Border.rounded 3
            ]
        ]
