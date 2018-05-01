module Main exposing (..)

import Element exposing (..)
import Element.Attributes exposing (..)
import Element.Events exposing (..)
import Html
import Links
import Login
import RemoteData exposing (..)
import Return exposing (..)
import Stylesheet exposing (..)


type Msg
    = MsgForLogin Login.Msg
    | MsgForLinks Links.Msg


type alias Model =
    { login : Login.Model
    , loggedInUser : Maybe Login.User
    , links : Links.Model
    }


init : Return Msg Model
init =
    Login.update Login.LoadLogin Login.init
        |> Return.mapCmd MsgForLogin
        |> Return.map
            (\login ->
                { login = login
                , loggedInUser = Nothing
                , links = Links.init
                }
            )


update : Msg -> Model -> Return Msg Model
update msg model =
    case msg of
        MsgForLogin (Login.LoginResponse (Success user)) ->
            Login.update (Login.LoginResponse (Success user)) model.login
                |> Return.map (\login -> { model | login = login, loggedInUser = Just user })
                |> Return.mapCmd MsgForLogin
                |> Return.andThen (update (MsgForLinks Links.LoadLinks))

        MsgForLogin (Login.LogoutResponse (Success _)) ->
            init

        MsgForLogin msg ->
            Login.update msg model.login
                |> Return.map (\login -> { model | login = login })
                |> Return.mapCmd MsgForLogin

        MsgForLinks msg ->
            Links.update msg model.links
                |> Return.map (\links -> { model | links = links })
                |> Return.mapCmd MsgForLinks


main : Program Never Model Msg
main =
    Html.program
        { init = init
        , update = update
        , view = view
        , subscriptions = \_ -> Sub.none
        }


view : Model -> Html.Html Msg
view model =
    Element.layout stylesheet <|
        column General
            [ center, width (percent 100) ]
            [ navigation model
            , column None
                [ width (percent 100), maxWidth (px 1200), paddingXY 40 40 ]
                [ case model.loggedInUser of
                    Nothing ->
                        Element.map MsgForLogin (Login.view model.login)

                    Just user ->
                        Element.map MsgForLinks (Links.view user model.links)
                ]
            ]


navigation : Model -> Element Styles variation Msg
navigation model =
    row Navigation
        [ spread, paddingXY 80 20, width (percent 100) ]
        [ el Logo [] (text "Fake News Detector Admin")
        , case model.loggedInUser of
            Nothing ->
                empty

            Just user ->
                row None
                    [ spacingXY 10 0 ]
                    [ text ("Signed in as " ++ user.email)
                    , button None [ onClick (MsgForLogin Login.Logout), paddingXY 10 0 ] (text "Logout")
                    ]
        ]
