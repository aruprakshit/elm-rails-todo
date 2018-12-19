module Page.Todos.New exposing (Msg(..), update, view)

import Browser.Navigation as Nav
import Decoders.Todos exposing (todoDecoder)
import Html exposing (Html, a, button, div, form, input, label, text, textarea)
import Html.Attributes exposing (href, placeholder, style, type_, value)
import Html.Events exposing (onInput, onSubmit)
import Http
import Json.Encode as JE
import Page.Home exposing (Todo)


type Msg
    = OnInputChange String String
    | CreateTodo
    | CreatedTodo (Result Http.Error Todo)


type alias Model =
    Todo


update : Nav.Key -> Msg -> Model -> ( Model, Cmd Msg )
update key msg model =
    case msg of
        OnInputChange name value ->
            if name == "title" then
                ( { model | title = value }, Cmd.none )

            else if name == "content" then
                ( { model | content = Just value }, Cmd.none )

            else
                ( model, Cmd.none )

        CreateTodo ->
            ( model, createTodo model )

        CreatedTodo response ->
            ( model, Nav.pushUrl key "/" )


view : Model -> Html Msg
view model =
    div []
        [ form [ onSubmit CreateTodo ]
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


createTodo : Model -> Cmd Msg
createTodo formData =
    Http.post
        { url = "http://localhost:3000/todos"
        , body = Http.jsonBody <| todoPayload formData
        , expect = Http.expectJson CreatedTodo todoDecoder
        }


todoPayload : Model -> JE.Value
todoPayload formData =
    JE.object
        [ ( "title", JE.string formData.title )
        , ( "content", JE.string (Maybe.withDefault "" formData.content) )
        , ( "completed", JE.bool formData.completed )
        ]
