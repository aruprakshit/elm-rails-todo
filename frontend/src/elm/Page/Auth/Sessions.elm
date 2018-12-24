module Page.Auth.Sessions exposing (Model, Msg(..), update, view)

import Browser.Navigation as Nav
import Config exposing (AuthState(..), backendDomain)
import Decoders.Auth exposing (authDecoder)
import Entities.Signin as Signin
import Html exposing (Html, a, button, div, form, input, label, text)
import Html.Attributes exposing (class, for, href, id, style, type_, value)
import Html.Events exposing (onInput, onSubmit)
import Http
import Json.Encode as JE
import Ports exposing (storeAuthInfo)
import Url.Builder as UB


type Msg
    = OnInputChange String String
    | LogInRequested
    | LoginCompleted (Result Http.Error Signin.AuthInfo)


type alias Model =
    Signin.Model


update : Nav.Key -> Msg -> Model -> ( Model, Cmd Msg, AuthState )
update key msg model =
    case msg of
        OnInputChange "email" value ->
            ( { model | email = value }, Cmd.none, NotAuthenticated )

        OnInputChange "password" value ->
            ( { model | password = value }, Cmd.none, NotAuthenticated )

        OnInputChange _ _ ->
            ( model, Cmd.none, NotAuthenticated )

        LogInRequested ->
            ( model, singIn model, NotAuthenticated )

        LoginCompleted response ->
            case response of
                Ok authData ->
                    ( model
                    , Cmd.batch
                        [ storeAuthInfo <| JE.string authData.authToken
                        , Nav.pushUrl key "/"
                        ]
                    , Authenticated authData.authToken
                    )

                Err _ ->
                    ( model, Cmd.none, NotAuthenticated )


view : Model -> Html Msg
view model =
    div [ class "row", style "height" "100vh" ]
        [ div [ class "col-6 m-auto" ]
            [ form [ onSubmit LogInRequested ]
                [ div [ class "form-group" ]
                    [ div [ class "col-8" ]
                        [ label [ for "sign-in-email" ] [ text "Email address" ]
                        , input
                            [ type_ "email"
                            , class "form-control"
                            , id "sign-in-email"
                            , onInput (OnInputChange "email")
                            , value model.email
                            ]
                            []
                        ]
                    ]
                , div [ class "form-group" ]
                    [ div [ class "col-8" ]
                        [ label [ for "sign-in-password" ] [ text "Password" ]
                        , input
                            [ type_ "password"
                            , class "form-control"
                            , id "sign-in-password"
                            , onInput (OnInputChange "password")
                            , value model.password
                            ]
                            []
                        ]
                    ]
                , div [ class "form-group" ]
                    [ div [ class "col-4" ]
                        [ button [ type_ "submit", class "btn btn-primary" ] [ text "Log In" ]
                        ]
                    ]
                ]
            ]
        ]


singIn : Model -> Cmd Msg
singIn formData =
    Http.post
        { url = backendDomain ++ UB.absolute [ "sessions" ] []
        , body = Http.jsonBody <| loginPayload formData
        , expect = Http.expectJson LoginCompleted authDecoder
        }


loginPayload : Model -> JE.Value
loginPayload formData =
    JE.object
        [ ( "email", JE.string formData.email )
        , ( "password", JE.string formData.password )
        ]
