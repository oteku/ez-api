open Js_of_ocaml
open EzRequest_lwt
open Fetch

let (>|=) = Lwt.(>|=)

let log ?(meth="GET") ?msg url = match msg with
  | None -> ()
  | Some msg -> Firebug.console##log (
      Js.string ("[>" ^ msg ^ " " ^ meth ^ " " ^ url ^ "]"))

let handle_response ?msg url r =
  match r with
  | Error s -> Error (0, Some s)
  | Ok r ->
    log ~meth:("RECV " ^ string_of_int r.status) ?msg url ;
    if r.status >= 200 && r.status < 300 then Ok r.body
    else Error (r.status, Some r.body)

include Make(struct

    let get ?(meth="GET") ?headers ?msg url =
      log ~meth ?msg url;
      fetch ?headers ~meth url to_text >|= (handle_response ?msg url)

    let post ?(meth="POST") ?(content_type="application/json") ?(content="{}") ?(headers=[]) ?msg url =
      log ~meth ?msg url;
      let headers = ("Content-Type", content_type) :: headers in
      fetch ~headers ~meth ~body:(RString content) url to_text >|= (handle_response ?msg url)

  end)

(* Use our own version of Ezjsonm.from_string to avoid errors *)
let init () =
  EzEncodingJS.init ();
  EzDebugJS.init ();
  init ();
  EzRequest_lwt.log := (fun s -> Firebug.console##log (Js.string s));
  !EzRequest_lwt.log "ezXhr Loaded"
