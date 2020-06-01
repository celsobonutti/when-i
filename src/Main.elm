port module Main exposing (main)

import Browser exposing (Document)
import Html exposing (..)
import Html.Attributes as Attrs
import Html.Events exposing (onInput, onSubmit)
import Html.Keyed as Keyed
import Html.Lazy exposing (lazy)


port saveAnnotations : List Annotation -> Cmd msg


main : Program (List Annotation) Model Msg
main =
    Browser.document
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


init : List Annotation -> ( Model, Cmd Msg )
init annotations =
    ( { annotations = annotations
      , thoughtText = ""
      , feelingText = ""
      }
    , Cmd.none
    )


type alias Annotation =
    { thought : String
    , feeling : String
    }


type alias Model =
    { annotations : List Annotation
    , thoughtText : String
    , feelingText : String
    }


type Msg
    = ChangeThought String
    | ChangeFeeling String
    | AddAnnotation


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ChangeThought thought ->
            ( { model
                | thoughtText = thought
              }
            , Cmd.none
            )

        ChangeFeeling feeling ->
            ( { model
                | feelingText = feeling
              }
            , Cmd.none
            )

        AddAnnotation ->
            let
                updatedAnnotations =
                    Annotation model.thoughtText model.feelingText :: model.annotations
            in
            ( { annotations = updatedAnnotations
              , thoughtText = ""
              , feelingText = ""
              }
            , saveAnnotations updatedAnnotations
            )


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none


view : Model -> Document Msg
view model =
    { title = "When I"
    , body = [ pageView model ]
    }


pageView : Model -> Html Msg
pageView model =
    div
        [ Attrs.class "content" ]
        [ form
            [ Attrs.class "form", onSubmit AddAnnotation ]
            [ label [ Attrs.class "form__label" ] [ text "When I think about..." ]
            , input
                [ Attrs.class "form__input"
                , Attrs.value model.thoughtText
                , Attrs.autofocus True
                , onInput ChangeThought
                ]
                []
            , label [ Attrs.class "form__label" ] [ text "I feel..." ]
            , input
                [ Attrs.class "form__input"
                , Attrs.value model.feelingText
                , onInput ChangeFeeling
                ]
                []
            , button
                [ Attrs.class "form__button"
                , Attrs.disabled
                    (String.isEmpty model.feelingText
                        || String.isEmpty model.thoughtText
                    )
                ]
                [ text "Add" ]
            , div []
                [ h2 [ Attrs.class "annotations__header" ]
                    [ text "Annotations" ]
                , feelingList model.annotations
                ]
            ]
        ]


feelingList : List Annotation -> Html Msg
feelingList annotations =
    case annotations of 
        [] ->
            h5 [] [ text "Oops, looks like you haven't recorded anything yet!"]
        _ ->
            Keyed.ol [] (List.map viewKeyedFeeling annotations)


viewKeyedFeeling : Annotation -> ( String, Html Msg )
viewKeyedFeeling annotation =
    ( annotation.thought, lazy viewFeeling annotation )


viewFeeling : Annotation -> Html Msg
viewFeeling annotation =
    li [ Attrs.class "annotations__item" ] [ text ("When I think about " ++ annotation.thought ++ ", I feel " ++ annotation.feeling) ]
