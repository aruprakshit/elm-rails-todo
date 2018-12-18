module Page.Todos.New exposing (Msg, update, view)

import Html exposing (Html, a, button, div, form, input, label, text, textarea)
import Html.Attributes exposing (href, placeholder, style, type_, value)
import Html.Events exposing (onInput)
import Page.Home exposing (Todo)


type Msg
    = OnInputChange String String


type alias Model =
    Todo


update : Msg -> Model -> Model
update msg model =
    case msg of
        OnInputChange name value ->
            if name == "title" then
                { model | title = value }

            else if name == "content" then
                { model | content = Just value }

            else
                model


view : Model -> Html Msg
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
                        , onInput (OnInputChange "title")
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
                        , onInput (OnInputChange "content")
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
