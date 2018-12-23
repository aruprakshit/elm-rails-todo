module Main exposing (main)

import Browser exposing (Document, UrlRequest(..))
import Browser.Navigation as Nav
import Config exposing (backendDomain)
import Decoders.Todos exposing (todoDecoder, todosListDecoder)
import Entities.Todo as Todo
import Entities.User as User
import Html exposing (Html, div, h1, text)
import Html.Attributes exposing (class)
import Http
import Json.Decode as JD
import Navigation exposing (Route(..), toRoute)
import Page.Auth.Sessions as SessionsPage
import Page.Home as HomePage
import Page.NotFound as PageNotFound
import Page.Todos.Edit as EditTodoPage
import Page.Todos.New as NewTodoPage
import Page.Todos.Show as ShowTodoPage
import Url exposing (Url)
import Url.Builder as UB
import Utils.Todo exposing (idToString)



-- MODEL


type alias Model =
    { key : Nav.Key
    , state : State
    }


type State
    = NewTodo Todo.Model
    | EditTodo (Maybe Todo.Model)
    | Home (List Todo.Model)
    | ShowTodo (Maybe Todo.Model)
    | NoPageFound
    | Session User.Model


initialModel : Nav.Key -> Model
initialModel key =
    Model key (Home [])



-- UPDATE


type Msg
    = ChangedUrl Url
    | ActivatedLink Browser.UrlRequest
    | GotTodos (Result Http.Error (List Todo.Model))
    | NewTodoPageMsg NewTodoPage.Msg
    | GotTodo (Result Http.Error Todo.Model)
    | HomePageMsg HomePage.Msg
    | EditTodoPageMsg EditTodoPage.Msg
    | SessionsPageMsg SessionsPage.Msg


getCurrentPageData : Model -> Url -> ( Model, Cmd Msg )
getCurrentPageData model url =
    case toRoute <| Url.toString url of
        Index ->
            ( model
            , fetchTodos
            )

        New ->
            ( { model | state = NewTodo Todo.initialModel }
            , Cmd.none
            )

        Show todoId ->
            ( { model | state = ShowTodo Nothing }
            , fetchTodo todoId
            )

        Edit todoId ->
            ( { model | state = EditTodo Nothing }
            , fetchTodo todoId
            )

        Login ->
            ( { model | state = Session User.initialModel }, Cmd.none )

        NotFound ->
            ( { model | state = NoPageFound }
            , Cmd.none
            )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case ( msg, model.state ) of
        ( EditTodoPageMsg editMsg, EditTodo todo ) ->
            EditTodoPage.update model.key editMsg (Maybe.withDefault Todo.initialModel todo)
                |> Tuple.mapFirst (\newTodo -> { model | state = EditTodo (Just newTodo) })
                |> Tuple.mapSecond (Cmd.map EditTodoPageMsg)

        ( HomePageMsg homeMsg, Home todos ) ->
            HomePage.update homeMsg todos
                |> Tuple.mapFirst (\newTodos -> { model | state = Home newTodos })
                |> Tuple.mapSecond (Cmd.map HomePageMsg)

        ( NewTodoPageMsg formControlMsg, NewTodo currentTodo ) ->
            NewTodoPage.update model.key formControlMsg currentTodo
                |> Tuple.mapFirst (\newTodo -> { model | state = NewTodo newTodo })
                |> Tuple.mapSecond (Cmd.map NewTodoPageMsg)

        ( SessionsPageMsg formControlMsg, Session currentUser ) ->
            SessionsPage.update model.key formControlMsg currentUser
                |> Tuple.mapFirst (\user -> { model | state = Session user })
                |> Tuple.mapSecond (Cmd.map SessionsPageMsg)

        ( ActivatedLink urlContainer, _ ) ->
            case urlContainer of
                Internal url ->
                    ( model, Nav.pushUrl model.key url.path )

                External path ->
                    ( model, Cmd.none )

        ( ChangedUrl url, _ ) ->
            getCurrentPageData model url

        ( GotTodo response, _ ) ->
            case response of
                Ok todo ->
                    case model.state of
                        ShowTodo _ ->
                            ( { model | state = ShowTodo (Just todo) }, Cmd.none )

                        EditTodo _ ->
                            ( { model | state = EditTodo (Just todo) }, Cmd.none )

                        _ ->
                            ( model, Cmd.none )

                Err _ ->
                    ( model, Cmd.none )

        ( GotTodos response, _ ) ->
            case response of
                Ok todos ->
                    ( { model | state = Home todos }, Cmd.none )

                Err _ ->
                    ( model, Cmd.none )

        ( _, _ ) ->
            -- Disregard messages that arrived for the wrong page.
            ( model, Cmd.none )



-- INIT


init : () -> Url -> Nav.Key -> ( Model, Cmd Msg )
init flags url navKey =
    getCurrentPageData (initialModel navKey) url



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none



-- VIEW


pageTitle : State -> String
pageTitle state =
    case state of
        Home _ ->
            "Home Page"

        NewTodo _ ->
            "Create a todo item"

        ShowTodo maybeTodo ->
            case maybeTodo of
                Just todo ->
                    todo.title

                Nothing ->
                    "Loading"

        EditTodo maybeTodo ->
            case maybeTodo of
                Just todo ->
                    todo.title

                Nothing ->
                    "Loading"

        Session _ ->
            "Log in"

        NoPageFound ->
            "Page not found"


pageBody : Model -> Html Msg
pageBody { key, state } =
    let
        body =
            case state of
                Home todos ->
                    HomePage.view todos |> Html.map HomePageMsg

                NewTodo todo ->
                    NewTodoPage.view todo |> Html.map NewTodoPageMsg

                ShowTodo todo ->
                    ShowTodoPage.view todo

                EditTodo todo ->
                    case todo of
                        Just formData ->
                            EditTodoPage.view formData |> Html.map EditTodoPageMsg

                        Nothing ->
                            text "Loading"

                Session user ->
                    SessionsPage.view user |> Html.map SessionsPageMsg

                NoPageFound ->
                    PageNotFound.view
    in
    div [ class "container" ]
        [ body
        ]


view : Model -> Document Msg
view model =
    { title = pageTitle model.state
    , body =
        [ pageBody model
        ]
    }



-- MAIN


main =
    Browser.application
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        , onUrlChange = ChangedUrl
        , onUrlRequest = ActivatedLink
        }


fetchTodos : Cmd Msg
fetchTodos =
    Http.get
        { url = backendDomain ++ UB.absolute [ "todos" ] []
        , expect = Http.expectJson GotTodos todosListDecoder
        }


fetchTodo : Int -> Cmd Msg
fetchTodo todoId =
    Http.get
        { url = backendDomain ++ UB.absolute [ "todos", String.fromInt todoId ] []
        , expect = Http.expectJson GotTodo todoDecoder
        }
