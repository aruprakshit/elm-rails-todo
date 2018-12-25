module Page.Auth.Registrations exposing (Model, Msg(..), update, view)

import Browser.Navigation as Nav
import Config exposing (AuthState(..), backendDomain)
import Decoders.Auth as AD exposing (authDecoder)
import Entities.Signup as Signup
import Html exposing (Html, a, button, div, form, input, label, text)
import Html.Attributes exposing (class, for, href, id, style, type_, value)
import Html.Events exposing (onInput, onSubmit)
import Http
import Json.Encode as JE
import Ports exposing (storeAuthInfo)
import Url.Builder as UB


type Msg
    = OnInputChange String String
    | SignupRequested
    | SignupCompleted (Result Http.Error AD.AuthInfo)


type alias Model =
    Signup.Model


update : Nav.Key -> Msg -> Model -> ( Model, Cmd Msg, AuthState )
update key msg model =
    case msg of
        OnInputChange "email" value ->
            ( { model | email = value }, Cmd.none, NotAuthenticated )

        OnInputChange "password" value ->
            ( { model | password = value }, Cmd.none, NotAuthenticated )

        OnInputChange "passwordConfirmation" value ->
            ( { model | passwordConfirmation = value }, Cmd.none, NotAuthenticated )

        OnInputChange _ _ ->
            ( model, Cmd.none, NotAuthenticated )

        SignupRequested ->
            ( model, singUp model, NotAuthenticated )

        SignupCompleted response ->
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
            [ form [ onSubmit SignupRequested ]
                [ div [ class "form-group" ]
                    [ div [ class "col-8" ]
                        [ label [ for "sign-up-email" ] [ text "Email address" ]
                        , input
                            [ type_ "email"
                            , class "form-control"
                            , id "sign-up-email"
                            , onInput (OnInputChange "email")
                            , value model.email
                            ]
                            []
                        ]
                    ]
                , div [ class "form-group" ]
                    [ div [ class "col-8" ]
                        [ label [ for "sign-up-password" ] [ text "Password" ]
                        , input
                            [ type_ "password"
                            , class "form-control"
                            , id "sign-up-password"
                            , onInput (OnInputChange "password")
                            , value model.password
                            ]
                            []
                        ]
                    ]
                , div [ class "form-group" ]
                    [ div [ class "col-8" ]
                        [ label [ for "sign-up-password-confirm" ] [ text "Password" ]
                        , input
                            [ type_ "password"
                            , class "form-control"
                            , id "sign-up-password-confirm"
                            , onInput (OnInputChange "passwordConfirmation")
                            , value model.password
                            ]
                            []
                        ]
                    ]
                , div [ class "form-group" ]
                    [ div [ class "col-4" ]
                        [ button [ type_ "submit", class "btn btn-primary" ] [ text "Sign Up" ]
                        ]
                    ]
                ]
            ]
        ]


singUp : Model -> Cmd Msg
singUp formData =
    Http.post
        { url = backendDomain ++ UB.absolute [ "registrations" ] []
        , body = Http.jsonBody <| singupPayload formData
        , expect = Http.expectJson SignupCompleted authDecoder
        }


singupPayload : Model -> JE.Value
singupPayload formData =
    JE.object
        [ ( "email", JE.string formData.email )
        , ( "password", JE.string formData.password )
        , ( "password_confirmation", JE.string formData.passwordConfirmation )
        ]
