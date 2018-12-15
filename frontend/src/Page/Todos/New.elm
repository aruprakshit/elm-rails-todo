module Page.Todos.New exposing (view)

import Html exposing (Html, a, button, div, form, input, label, text, textarea)
import Html.Attributes exposing (href, placeholder, style, type_, value)
import Page.Home exposing (Todo)


view : Todo -> Html msg
view model =
    div []
        [ form []
            [ div [ style "margin-bottom" "10px" ]
                [ label []
                    [ text "Title:"
                    , input
                        [ type_ "text"
                        , placeholder "Title"
                        , style "margin-left" "10px"
                        , value model.title
                        ]
                        []
                    ]
                ]
            , div [ style "margin-bottom" "10px" ]
                [ label []
                    [ text "Content:"
                    , textarea
                        [ placeholder "Content"
                        , style "margin-left" "10px"
                        , value (Maybe.withDefault "" model.content)
                        ]
                        []
                    ]
                ]
            , div []
                [ button [] [ text "Save" ]
                ]
            ]
        , a [ href "/" ] [ text "Back" ]
        ]
