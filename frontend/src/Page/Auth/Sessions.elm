module Page.Auth.Sessions exposing (view)

import Html exposing (Html, a, button, div, form, input, label, text)
import Html.Attributes exposing (class, for, href, id, style, type_, value)
import Html.Events exposing (onClick, onInput)


view : Html msg
view =
    div [ class "row", style "height" "100vh" ]
        [ div [ class "col-6 m-auto" ]
            [ form []
                [ div [ class "form-group" ]
                    [ div [ class "col-8" ]
                        [ label [ for "sign-in-email" ] [ text "Email address" ]
                        , input [ type_ "email", class "form-control", id "sign-in-email" ] []
                        ]
                    ]
                , div [ class "form-group" ]
                    [ div [ class "col-8" ]
                        [ label [ for "sign-in-password" ] [ text "Password" ]
                        , input [ type_ "password", class "form-control", id "sign-in-password" ] []
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
