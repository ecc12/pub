
package main

import (
    "fmt"
    "io/ioutil"
    "net/http"
    "github.com/gorilla/mux"
    "stablelib.com/v1/blackfriday"
)

func main() {
    RouteInit()
    http.ListenAndServe("0.0.0.0:8080", nil)        
}

// configure the routes
// GET /pg/[0-9a-zA-Z-\_]+ -> PageHandler
// default -> static ./assets/
func RouteInit() {
    router := mux.NewRouter().StrictSlash(false)
    router.HandleFunc("/pg/{id:[0-9a-zA-Z\\-_]+}", PageHandler)
    router.HandleFunc("/pg/{id:[0-9a-zA-Z\\-_]+}.txt", SrcHandler)
    router.HandleFunc("/", IndexHandler)
    router.PathPrefix("/").Handler(http.FileServer(http.Dir("./assets/")))

    http.Handle("/", router)
}

// handle requests to /pg/[0-9a-zA-Z-\_]+.txt by delivering the raw contents of ./pg/ID.txt
func SrcHandler(w http.ResponseWriter, r *http.Request) {
    vars := mux.Vars(r)
    fmt.Fprint(w, GetSource(vars["id"]))
}

// handle requests to /pg/[0-9a-zA-Z-\_]+ by sourcing Markdown from ./pg/ID.txt
func PageHandler(w http.ResponseWriter, r *http.Request) {
    vars := mux.Vars(r)
    fmt.Fprint(w, GetPage(vars["id"]))
}

// handle requests to / by sourcing Markdown from ./pg/index.txt
func IndexHandler(w http.ResponseWriter, r *http.Request) {
    fmt.Fprint(w, GetPage("index"))
}

// read page from disk and return HTML
func GetPage(id string) string {
  return MarkdownStringToHtml(GetSource(id))
}

// read page from disk and return raw text
func GetSource(id string) string {
  if content, err := ioutil.ReadFile(fmt.Sprintf("./pg/%s.txt", id)); err == nil {
    return string(content)
  }
  return "error"
} 

// convert markdown to html
func MarkdownStringToHtml(md string) string {
  return string(MarkdownBytesToHtml([]byte(md)))
}

// convert markdown to html
func MarkdownBytesToHtml(md []byte) []byte {
  return blackfriday.MarkdownCommon(md)
}
