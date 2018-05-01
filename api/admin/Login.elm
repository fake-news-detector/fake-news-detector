module Login exposing (..)

import Element exposing (..)
import Element.Attributes exposing (..)
import Element.Events exposing (..)
import Form exposing (Form)
import Form.Input as Input
import Form.Validate as Validate exposing (..)
import Html
import Http exposing (Error(..))
import Json.Decode as Decode exposing (..)
import Json.Decode.Pipeline exposing (..)
import Json.Encode as Encode exposing (..)
import RemoteData exposing (..)
import RemoteData.Http exposing (..)
import Return exposing (..)
import Stylesheet exposing (..)


type Msg
    = LoadLogin
    | FormMsg Form.Msg
    | LoginResponse (WebData User)
    | Logout
    | LogoutResponse (WebData ())


type alias Model =
    { form : Form () LoginForm
    , response : WebData User
    }


type alias LoginForm =
    { email : String
    , password : String
    }


type alias User =
    { email : String
    }


init : Model
init =
    { form = Form.initial [] validation, response = NotAsked }


validation : Validation () LoginForm
validation =
    Validate.map2 LoginForm
        (Validate.field "email" Validate.email)
        (Validate.field "password" Validate.string)


userDecoder : Decoder User
userDecoder =
    decode User
        |> required "email" Decode.string


loginEncoder : LoginForm -> Encode.Value
loginEncoder loginForm =
    Encode.object
        [ ( "email", Encode.string loginForm.email )
        , ( "password", Encode.string loginForm.password )
        ]


update : Msg -> Model -> Return Msg Model
update msg model =
    case msg of
        LoadLogin ->
            return model (RemoteData.Http.get "/admin/login" LoginResponse userDecoder)

        FormMsg formMsg ->
            case ( formMsg, Form.getOutput model.form ) of
                ( Form.Submit, Just loginForm ) ->
                    return { model | response = Loading }
                        (RemoteData.Http.post "/admin/login"
                            LoginResponse
                            userDecoder
                            (loginEncoder loginForm)
                        )

                _ ->
                    return { model | form = Form.update validation formMsg model.form } Cmd.none

        LoginResponse response ->
            return { model | response = response } Cmd.none

        Logout ->
            return model (RemoteData.Http.post "/admin/logout" LogoutResponse (Decode.succeed ()) (Encode.object []))

        LogoutResponse response ->
            case response of
                Success _ ->
                    return init Cmd.none

                _ ->
                    return model Cmd.none


view : Model -> Element Styles variation Msg
view model =
    column None
        []
        [ h1 Title [ paddingBottom 30 ] (text "Login")
        , loginForm model.form
        , case model.response of
            Loading ->
                text "Loading..."

            Success user ->
                text ("Signed in as " ++ user.email)

            Failure error ->
                case error of
                    BadStatus response ->
                        if response.status.code == 404 then
                            empty
                        else
                            text response.status.message

                    _ ->
                        text "Error signing in"

            NotAsked ->
                empty
        ]


loginForm : Form e o -> Element Styles variation Msg
loginForm form =
    let
        errorFor field =
            case field.liveError of
                Just error ->
                    text (toString error)

                Nothing ->
                    text ""

        email =
            Form.getFieldAsString "email" form

        password =
            Form.getFieldAsString "password" form
    in
    node "form" <|
        column None
            []
            [ row None
                []
                [ el None [ width (px 80) ] (text "Email")
                , html <| Html.map FormMsg (Input.textInput email [])
                ]
            , errorFor email
            , row None
                []
                [ el None [ width (px 80) ] (text "Password")
                , html <| Html.map FormMsg (Input.passwordInput password [])
                ]
            , errorFor password
            , button None
                [ onClickStopPropagation (FormMsg Form.Submit), width (px 200), paddingXY 0 10 ]
                (text "Enter")
            ]


onClickStopPropagation : msg -> Element.Attribute variation msg
onClickStopPropagation msg =
    onWithOptions "click"
        { defaultOptions | stopPropagation = True, preventDefault = True }
        (Decode.succeed msg)
