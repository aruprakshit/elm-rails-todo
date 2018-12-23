module Page.Auth.Sessions exposing (Model, Msg(..), update, view)

import Browser.Navigation as Nav
import Entities.User as User
import Html exposing (Html, a, button, div, form, input, label, text)
import Html.Attributes exposing (class, for, href, id, style, type_, value)
import Html.Events exposing (onClick, onInput)


type Msg
    = OnInputChange String String


type alias Model =
    User.Model


update : Nav.Key -> Msg -> Model -> ( Model, Cmd Msg )
update key msg model =
    case msg of
        OnInputChange "email" value ->
            ( { model | email = value }, Cmd.none )

        OnInputChange "password" value ->
            ( { model | password = value }, Cmd.none )

        OnInputChange _ _ ->
            ( model, Cmd.none )


view : Model -> Html Msg
view model =
    div [ class "row", style "height" "100vh" ]
        [ div [ class "col-6 m-auto" ]
            [ form []
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
