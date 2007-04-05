(* Ocsigen
 * http://www.ocsigen.org
 * Module eliom.mli
 * Copyright (C) 2007 Vincent Balat
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation, with linking exception; 
 * either version 2.1 of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
 *)


(** Eliom.ml defines the functions you need to interact with the
   Eliommod module:
   - To create the "typed services" and associate them to a path (directories/name)
   - To specify the types and names of the parameters of this service
   - To register the functions that generate pages for each of these services
   - To create links or forms etc.
 *)

open XHTML.M
open Xhtmltypes
open Extensions

(** Allows extensions of the configuration file for your modules *)
val get_config : unit -> 
  Simplexmlparser.ExprOrPatt.texprpatt Simplexmlparser.ExprOrPatt.tlist
(** Put your options between <module ...> and </module> *)

(** This function may be used for services that can not be interrupted
  (no cooperation point for threads). It is defined by
  [let sync f sp g p = Lwt.return (f sp g p)]
 *)
val sync : ('a -> 'b -> 'c -> 'd) -> ('a -> 'b -> 'c -> 'd Lwt.t)

(** {2 Types} *)
type suff = [ `WithSuffix | `WithoutSuffix ]

type servcoserv = [ `Service | `Coservice ]
type getpost = [ `Get | `Post ]
      (* `Post means that there is at least one post param
         (possibly only the state post param).
         `Get is for all the other cases.
       *)
type attached_service_kind = 
    [ `Internal of servcoserv * getpost
    | `External]

type get_attached_service_kind = 
    [ `Internal of servcoserv * [ `Get ]
    | `External ]

type post_attached_service_kind = 
    [ `Internal of servcoserv * [ `Post ]
    | `External ]

type internal = 
    [ `Internal of servcoserv * getpost ]

type registrable = [ `Registrable | `Unregistrable ]
(** You can call register function only on registrable services *)
(* Registrable means not pre-applied *)

type +'a a_s
      
type +'a na_s

type service_kind =
    [ `Attached of attached_service_kind a_s
  | `Nonattached of getpost na_s ]

type get_service_kind =
    [ `Attached of get_attached_service_kind a_s
  | `Nonattached of [ `Get ] na_s ]

type post_service_kind =
    [ `Attached of post_attached_service_kind a_s
  | `Nonattached of [ `Post ] na_s ]

type internal_service_kind =
    [ `Attached of internal a_s
  | `Nonattached of getpost na_s ]

type attached =
    [ `Attached of attached_service_kind a_s ]

type nonattached =
    [ `Nonattached of getpost na_s ]

type ('get,'post,+'kind,+'tipo,+'getnames,+'postnames,+'registr) service
(** Typed services. The ['kind] parameter is a subset of service_kind. ['get] 
   and ['post] are the type of GET and POST parameters. *)


type url_path = string list
(** This type is used to represent URL paths; For example the path [coucou/ciao] is represented by the list [\["coucou";"ciao"\]] *)

(** {2 Types of pages parameters} *)

(** Here are some examples of how to specify the types and names of pages parameters:
   - [unit] for a page without parameter.
   - [(int "myvalue")] for a page that takes one parameter, of type [int], called [myvalue]. (You must register a function of type [int ->] {{:#TYPEpage}[page]}).
   - [(int "myvalue" ** string "mystring")] for a page that takes two parameters, one of type [int] called [myvalue], and one of type [string] called [mystring]. (The function you will register has a parameter of type [(int * string)]).
   - [list "l" (int "myvalue" ** string "mystring")] for a page that takes a list of pairs. (The function you will register has a parameter of type [(int * string) list]).

 *)

type server_params
(** Type of server parameters *)
val get_user_agent : server_params -> string
val get_hostname : server_params -> string option
val get_full_url : server_params -> string
val get_inet_addr : server_params -> Unix.inet_addr
val get_ip : server_params -> string
val get_port : server_params -> int
val get_get_params : server_params -> (string * string) list
val get_post_params : server_params -> (string * string) list Lwt.t
val get_current_path : server_params -> url_path
val get_current_path_string : server_params -> string
val get_other_get_params : server_params -> (string * string) list
val get_suffix : server_params -> url_path
val get_exn : server_params -> exn list



(** Type of files *)
val get_tmp_filename : file_info -> string
val get_filesize : file_info -> int64
val get_original_filename : file_info -> string

type ('a, 'b) binsum = Inj1 of 'a | Inj2 of 'b
(** Binary sums *)

type 'a param_name
(** Type for names of page parameters *)

type ('a, 'b, 'c) params_type
(** Type for parameters of a web page *)

type 'an listnames =
    {it:'el 'a. ('an -> 'el -> 'a list) -> 'el list -> 'a list -> 'a list}
(** Type of the iterator used to construct forms from lists *)

val int : string -> (int, [ `WithoutSuffix ], int param_name) params_type
(** [int s] tells that the page takes an integer as parameter, labeled [s] *)

val float : string -> (float, [ `WithoutSuffix ], float param_name) params_type
(** [float s] tells that the page takes a floating point number as parameter, labeled [s] *)

val string :
    string -> (string, [ `WithoutSuffix ], string param_name) params_type
(** [string s] tells that the page takes a string as parameter, labeled [s] *)

val bool :
    string -> (bool, [ `WithoutSuffix ], bool param_name) params_type
(** [bool s] tells that the page takes a boolean as parameter, labeled [s]
   (to use for example with boolean checkboxes) *)

val file :
    string -> (file_info, [ `WithoutSuffix ], 
               file_info param_name) params_type
(** [file s] tells that the page takes a file as parameter, labeled [s] *)

val radio_answer :
    string -> (string option, [ `WithoutSuffix ], 
               string option param_name) params_type
(** [radio_answer s] tells that the page takes the result of a click on
   a radio button as parameter. *)

val unit : (unit, [ `WithoutSuffix ], unit param_name) params_type
(** used for pages that don't have any parameters *)

val user_type :
    (string -> 'a) ->
      ('a -> string) -> string -> ('a, [ `WithoutSuffix ], 'a param_name) params_type
(** Allows to use whatever type you want for a parameter of the page.
   [user_type s_to_t t_to_s s] tells that the page take a parameter, labeled [s], and that the server will have to use [s_to_t] and [t_to_s] to make the conversion from and to string.
 *)

val sum :
    ('a, [ `WithoutSuffix ], 'b) params_type ->
      ('a, [ `WithoutSuffix ], 'b) params_type ->
        (('a, 'a) binsum, [ `WithoutSuffix ], 'b * 'b) params_type
val prod :
    ('a, [ `WithoutSuffix ], 'b) params_type ->
      ('c, [ `WithoutSuffix ], 'd) params_type ->
        ('a * 'c, [ `WithoutSuffix ], 'b * 'd) params_type
(** See [**] above *)

val opt :
    ('a, [ `WithoutSuffix ], 'b) params_type ->
      ('a option, [ `WithoutSuffix ], 'b) params_type
(** Use this if you want a parameter to be optional *)

val list :
    string ->
      ('a, [ `WithoutSuffix ], 'b) params_type ->
        ('a list, [ `WithoutSuffix ], 'b listnames) params_type
(** The page takes a list of parameters. 
   The first parameter of this function is the name of the list. *)

val ( ** ) :
    ('a, [ `WithoutSuffix ], 'b) params_type ->
      ('c, [ `WithoutSuffix ], 'd) params_type ->
        ('a * 'c, [ `WithoutSuffix ], 'b * 'd) params_type
(** This is a combinator to allow the page to take several parameters (see examples above) Warning: it is a binary operator. Pages cannot take tuples but only pairs. *)

val suffix_only : (string, [ `WithSuffix ], string param_name) params_type
(** Tells that the only parameter of the function that will generate the page is the suffix of the URL of the current page. (see {{:#VALregister_new_service}[register_new_service]}) *)

val suffix :
    ('a, [ `WithoutSuffix ], 'b) params_type ->
      (string * 'a, [ `WithSuffix ], string param_name * 'b) params_type
(** Tells that the function that will generate the page takes a pair whose first element is the suffix of the URL of the current page. (see {{:#VALregister_new_service}[register_new_service]}). e.g. [suffix (int "i" ** string "s")] *)








(***** Static dir and actions do not depend on the type of pages ******)

(** {2 Misc} *)
val static_dir :
    server_params -> 
      (string, unit, [> `Attached of 
        [> `Internal of [> `Service ] * [> `Get] ] a_s ],
       [ `WithSuffix ],
       string param_name, unit param_name, [> `Unregistrable ])
        service
(** The service that correponds to the directory where static pages are.
   This directory is chosen in the config file (ocsigen.conf).
   This service takes the name of the static file as a parameter.
 *)

val close_session : server_params -> unit
(** Close the session *)
    

(** {2 Definitions of entry points (services/URLs)} *)
val new_service :
    url:url_path ->
      ?suffix:bool ->
        get_params:('get, [< suff ] as 'tipo,'gn)
          params_type ->
            unit ->
              ('get,unit,
               [> `Attached of 
                 [> `Internal of [> `Service ] * [>`Get] ] a_s ],
               'tipo,'gn, 
               unit param_name, [> `Registrable ]) service
(** [new_service ~url:p ~get_params:pa ()] creates an {{:#TYPEservice}[service]} associated to the {{:#TYPEurl_path}[url_path]} [p] and that takes the parameters [pa]. 
   
   If you specify [~suffix:true], your service will match all requests from client beginning by [path]. You can have access to the suffix of the URL using {{:VALsuffix}[suffix]} or {{:VALsuffix_only}[suffix_only]}. For example [new_service ["mysite";"mywiki"] ~suffix:true suffix_only] will match all the URL of the shape [http://myserver/mysite/mywiki/thesuffix]*)
	      
val new_external_service :
    url:url_path ->
      ?suffix:bool ->
        get_params:('get, [< suff ] as 'tipo, 'gn) params_type ->
          post_params:('post, [ `WithoutSuffix ], 'pn) params_type ->
            unit -> 
              ('get, 'post, [> `Attached of [> `External ] a_s ], 'tipo, 
               'gn, 'pn, [> `Unregistrable ]) service
(** Creates an service for an external web site *)
		
val new_coservice :
    fallback: 
    (unit, unit, [ `Attached of [ `Internal of [ `Service ] * [`Get]] a_s ],
     [`WithoutSuffix] as 'tipo,
     unit param_name, unit param_name, [< registrable ]) service ->
       get_params: 
         ('get,[`WithoutSuffix],'gn) params_type ->
           ('get,unit,[> `Attached of 
             [> `Internal of [> `Coservice] * [> `Get]] a_s ],
            'tipo, 'gn, unit param_name, 
            [> `Registrable ]) service
(** Creates another version of an already existing service, where you can register another treatment. The two versions are automatically distinguished thanks to an extra parameter. It allows to have several links towards the same page, that will behave differently. See the tutorial for more informations.*)

val new_coservice' :
    get_params: 
    ('get,[`WithoutSuffix],'gn) params_type ->
      ('get, unit, [> `Nonattached of [> `Get] na_s ],
       [`WithoutSuffix], 'gn, unit param_name, [> `Registrable ]) service
(** Creates a non-attached coservice. Links towards such services will not change the URL, just add extra parameters. *)
        
val new_post_service :
    fallback: ('get, unit, 
               [`Attached of [`Internal of 
                 ([ `Service | `Coservice ] as 'kind) * [`Get]] a_s ],
               [< suff] as 'tipo, 'gn, unit param_name, 
               [< `Registrable ]) service ->
                 post_params: ('post,[`WithoutSuffix],'pn) params_type ->
                   ('get, 'post, [> `Attached of 
                     [> `Internal of 'kind * [> `Post]] a_s ],
                    'tipo, 'gn, 'pn, [> `Registrable ]) service
(** Creates an service that takes POST parameters. 
   [fallback] is the same service without POST parameters.
   You can create an service with POST parameters if the same service does not exist
   without POST parameters. Thus, the user can't bookmark a page that does not
   exist.
 *)
(* fallback must be registrable! (= not preapplied) *)
	  
val new_post_coservice :
    fallback: ('get, unit, [ `Attached of 
      [`Internal of [<`Service | `Coservice] * [`Get]] a_s ],
               [< suff ] as 'tipo,
               'gn, unit param_name, [< `Registrable ]) service ->
                 post_params: ('post,[`WithoutSuffix],'pn) params_type ->
                  ('get, 'post, 
                   [> `Attached of 
                     [> `Internal of [> `Coservice] * [> `Post]] a_s ],
                   'tipo, 'gn, 'pn, [> `Registrable ]) service
(** Creates a coservice with POST parameters *)

val new_post_coservice' :
    post_params: ('post,[`WithoutSuffix],'pn) params_type ->
      (unit, 'post, 
       [> `Nonattached of [> `Post] na_s ],
       [ `WithoutSuffix ], unit param_name, 'pn, [> `Registrable ]) service
(** Creates a non attached coservice with POST parameters *)

(*
val new_get_post_coservice' :
    fallback: ('get, unit, [`Nonattached of [`Get] na_s ],
               [< suff ] as 'tipo,
               'gn, unit param_name, [< `Registrable ]) service ->
                 post_params: ('post,[`WithoutSuffix],'pn) params_type ->
                   ('get, 'post, 
                    [> `Nonattached of [> `Post] na_s ],
                    'tipo,'gn,'pn, [> `Registrable ]) service
(* * Creates a non-attached coservice with GET and POST parameters. The fallback is a non-attached coservice with GET parameters. *)
*)

val preapply :
    ('a, 'b, [> `Attached of 'd a_s ] as 'c,
     [< suff ], 'e, 'f, 'g)
    service ->
      'a -> 
        (unit, 'b, 'c, 
         [ `WithoutSuffix ], unit param_name, 'f, [ `Unregistrable ]) service
 




(** {2 Using other ways (than the module Eliom.Xhtml) to create pages} *)

module type REGCREATE = 
  sig
    type page

    val send : content:page -> Predefined_senders.result_to_send

  end


module type FORMCREATE = 
  sig
    type form_content_elt
    type form_content_elt_list
    type form_elt
    type a_content_elt
    type a_content_elt_list
    type a_elt
    type a_elt_list
    type div_content_elt
    type div_content_elt_list
    type uri
    type link_elt
    type script_elt
    type textarea_elt
    type select_elt
    type input_elt
    type pcdata_elt

    type a_attrib_t
    type form_attrib_t
    type input_attrib_t
    type textarea_attrib_t
    type select_attrib_t
    type link_attrib_t
    type script_attrib_t
    type input_type_t

    val hidden : input_type_t
    val text : input_type_t
    val password : input_type_t
    val checkbox : input_type_t
    val radio : input_type_t
    val submit : input_type_t
    val file : input_type_t

    val empty_seq : form_content_elt_list
    val cons_form : form_content_elt -> form_content_elt_list -> form_content_elt_list 

    val make_a : ?a:a_attrib_t -> href:string -> a_content_elt_list -> a_elt
    val make_get_form : ?a:form_attrib_t -> 
      action:string -> 
        form_content_elt -> form_content_elt_list -> form_elt
    val make_post_form : ?a:form_attrib_t ->
      action:string -> ?id:string -> ?inline:bool -> 
        form_content_elt -> form_content_elt_list -> form_elt
    val make_hidden_field : input_elt -> form_content_elt
    val remove_first : form_content_elt_list -> form_content_elt * form_content_elt_list
    val make_input : ?a:input_attrib_t -> ?checked:bool ->
      typ:input_type_t -> ?name:string -> 
        ?value:string -> unit -> input_elt
    val make_textarea : ?a:textarea_attrib_t -> 
      name:string -> rows:int -> cols:int ->
        pcdata_elt -> 
          textarea_elt
     val make_select : ?a:select_attrib_t ->
       name:string ->
       ?selected:((string option * string) option)
         -> (string option * string) -> ((string option * string) list) ->
       select_elt
    val make_div : classe:(string list) -> a_elt -> form_content_elt
    val make_uri_from_string : string -> uri


    val make_css_link : ?a:link_attrib_t -> uri -> link_elt

    val make_js_script : ?a:script_attrib_t -> uri -> script_elt

  end

module type ELIOMFORMSIG =
  sig

    type form_content_elt
    type form_content_elt_list
    type form_elt
    type a_content_elt
    type a_content_elt_list
    type a_elt
    type a_elt_list
    type div_content_elt
    type div_content_elt_list
    type uri
    type link_elt
    type script_elt
    type textarea_elt
    type select_elt
    type input_elt
    type pcdata_elt
          
    type a_attrib_t
    type form_attrib_t
    type input_attrib_t
    type textarea_attrib_t
    type select_attrib_t
    type link_attrib_t
    type script_attrib_t
    type input_type_t

    val a :
        ?a:a_attrib_t ->
          ('get, unit, [< get_service_kind ], 
           [< suff ], 'gn, unit param_name,
           [< registrable ]) service ->
            server_params -> a_content_elt_list -> 'get -> a_elt
    val get_form :
        ?a:form_attrib_t ->
          ('get, unit, [< get_service_kind ],
           [<suff ], 'gn, unit param_name, 
           [< registrable ]) service ->
             server_params ->
              ('gn -> form_content_elt_list) -> form_elt
    val post_form :
        ?a:form_attrib_t ->
          ('get, 'post, [< post_service_kind ],
           [< suff ], 'gn, 'pn, 
           [< registrable ]) service ->
            server_params ->
              ('pn -> form_content_elt_list) -> 'get -> form_elt
    val make_uri :
        ('get, unit, [< get_service_kind ],
         [< suff ], 'gn, unit param_name, 
         [< registrable ]) service ->
          server_params -> 'get -> uri

    val js_script :
        ?a:script_attrib_t -> uri -> script_elt
    val css_link : ?a:link_attrib_t -> uri -> link_elt

    val int_input :
        ?a:input_attrib_t -> ?value:int -> int param_name -> input_elt
    val float_input :
        ?a:input_attrib_t -> ?value:float -> float param_name -> input_elt
    val string_input :
        ?a:input_attrib_t -> ?value:string -> string param_name -> input_elt
    val user_type_input :
        ?a:input_attrib_t -> ?value:'a -> ('a -> string) -> 
          'a param_name -> input_elt
    val int_password_input :
        ?a:input_attrib_t -> ?value:int -> int param_name -> input_elt
    val float_password_input :
        ?a:input_attrib_t -> ?value:float -> float param_name -> input_elt
    val string_password_input :
        ?a:input_attrib_t -> ?value:string -> string param_name -> input_elt
    val user_type_password_input :
        ?a:input_attrib_t -> ?value:'a -> ('a -> string) -> 
          'a param_name -> input_elt
    val hidden_int_input :
        ?a:input_attrib_t -> int param_name -> int -> input_elt
    val hidden_float_input :
        ?a:input_attrib_t -> float param_name -> float -> input_elt
    val hidden_string_input :
        ?a:input_attrib_t -> string param_name -> string -> input_elt
    val hidden_user_type_input :
        ?a:input_attrib_t -> ('a -> string) -> 'a param_name -> 'a -> input_elt
    val bool_checkbox :
        ?a:input_attrib_t -> ?checked:bool -> bool param_name -> input_elt
    val string_radio :
        ?a:input_attrib_t -> ?checked:bool -> 
          string option param_name -> string -> input_elt
    val int_radio :
        ?a:input_attrib_t -> ?checked:bool -> 
           int option param_name -> int -> input_elt
    val float_radio :
        ?a:input_attrib_t -> ?checked:bool -> 
           float option param_name -> float -> input_elt
    val user_type_radio :
        ?a:input_attrib_t -> ?checked:bool -> ('a -> string) ->
           'a option param_name -> 'a -> input_elt
    val textarea :
        ?a:textarea_attrib_t ->
          string param_name ->
            rows:int -> cols:int -> pcdata_elt -> textarea_elt
    val select :
      ?a:select_attrib_t ->
      ?selected:((string option * string) option)
      -> (string option * string) -> ((string option * string) list) ->
      string param_name
      -> select_elt
    val submit_input : ?a:input_attrib_t -> string -> input_elt
    val file_input : ?a:input_attrib_t -> ?value:string -> 
                            file_info param_name-> input_elt

  end

module type ELIOMREGSIG =
  sig

    type page

    val register :
        service:('get, 'post,
                 [< internal_service_kind ],
                 [< suff ], 'gn, 'pn, [ `Registrable ]) service ->
        ?error_handler:(server_params ->
                               (string * exn) list -> page Lwt.t) ->
        (server_params -> 'get -> 'post -> page Lwt.t) ->
          unit
(** Register an service in the global table of the server 
   with the associated generation function.
   [register service t f] will associate the service [service] to the function [f].
   [f] is the function that creates a page. 
   It takes three parameters. The first one has type [server_params]
   and allows to have acces to informations about the request.
   The second and third ones are respectively GET and POST parameters.
   For example if [t] is (int "s"), then ['a] is int.
 *)

    val register_for_session :
        server_params ->
          service:('get, 'post, [< internal_service_kind ],
                   [< suff ], 'gn, 'pn, [ `Registrable ]) service ->
              ?error_handler:(server_params -> (string * exn) list -> 
                page Lwt.t) ->
                  (server_params -> 'get -> 'post -> page Lwt.t) -> unit
(** Registers an service and the associated function in the session table.
   If the same client does a request to this service, this function will be
   used instead of the one from the global table.

   Warning:
   - All service must be registered in the global table during initialisation,
   but never after,
   - You (obviously) can't register an service in a session table 
   when no session is active
 *)


    val register_new_service :
        url:url_path ->
          ?suffix:bool ->
            get_params:('get, [< suff ] as 'tipo, 'gn)
              params_type ->
                ?error_handler:(server_params -> (string * exn) list -> 
                  page Lwt.t) ->
                    (server_params -> 'get -> unit -> page Lwt.t) ->
                      ('get, unit, 
                       [> `Attached of 
                         [> `Internal of [> `Service ] * [> `Get] ] a_s ],
                       'tipo, 'gn, unit param_name, 
                       [> `Registrable ]) service
(** Same as [new_service] followed by [register] *)
                      
    val register_new_coservice :
        fallback:(unit, unit, 
                  [ `Attached of [ `Internal of [ `Service ] * [`Get]] a_s ],
                   [ `WithoutSuffix ] as 'tipo, 
                   unit param_name, unit param_name, [< registrable ])
        service ->
          get_params: 
            ('get, [`WithoutSuffix], 'gn) params_type ->
              ?error_handler:(server_params -> 
                (string * exn) list -> page Lwt.t) ->
                  (server_params -> 'get -> unit -> page Lwt.t) ->
                    ('get, unit, 
                     [> `Attached of 
                       [> `Internal of [> `Coservice ] * [> `Get]] a_s ], 
                     'tipo, 'gn, unit param_name, 
                     [> `Registrable ])
                      service
(** Same as [new_coservice] followed by [register] *)

    val register_new_coservice' :
        get_params: 
        ('get, [`WithoutSuffix] as 'tipo, 'gn) params_type ->
          ?error_handler:(server_params -> 
            (string * exn) list -> page Lwt.t) ->
              (server_params -> 'get -> unit -> page Lwt.t) ->
                ('get, unit, 
                 [> `Nonattached of [> `Get] na_s ],
                 'tipo, 'gn, unit param_name, [> `Registrable ])
                  service
(** Same as [new_coservice'] followed by [register] *)

    val register_new_coservice_for_session :
        server_params ->
          fallback:(unit, unit, 
                    [ `Attached of [ `Internal of [ `Service ] * [`Get]] a_s ],
                    [ `WithoutSuffix ] as 'tipo, 
                    unit param_name, unit param_name, [< registrable ])
            service ->
              get_params: 
                ('get, [`WithoutSuffix] as 'tipo, 'gn) params_type ->
                  ?error_handler:(server_params -> (string * exn) list -> 
                    page Lwt.t) ->
                      (server_params -> 'get -> unit -> page Lwt.t) ->
                        ('get, unit, 
                         [> `Attached of 
                           [> `Internal of [> `Coservice ] * [> `Get] ] a_s ], 
                         'tipo, 'gn, unit param_name, 
                         [> `Registrable ])
                          service
(** Same as [new_coservice] followed by [register_for_session] *)

    val register_new_coservice_for_session' :
        server_params ->
          get_params: 
            ('get, [`WithoutSuffix] as 'tipo, 'gn) params_type ->
              ?error_handler:(server_params -> (string * exn) list -> 
                page Lwt.t) ->
                  (server_params -> 'get -> unit -> page Lwt.t) ->
                    ('get, unit, [> `Nonattached of [> `Get] na_s ], 
                     'tipo, 'gn, unit param_name, 
                     [> `Registrable ])
                      service
(** Same as [new_coservice'] followed by [register_for_session] *)

    val register_new_post_service :
        fallback:('get, unit, 
                  [ `Attached of [ `Internal of 
                    ([ `Service | `Coservice ] as 'kind) * [`Get] ] a_s ],
                  [< suff ] as 'tipo, 'gn,
                  unit param_name, [< `Registrable ])
        service ->
          post_params:('post, [ `WithoutSuffix ], 'pn) params_type ->
            ?error_handler:(server_params -> (string * exn) list -> 
              page Lwt.t) ->
                (server_params -> 'get -> 'post -> page Lwt.t) ->
                  ('get, 'post, [> `Attached of
                    [> `Internal of 'kind * [> `Post] ] a_s ], 
                   'tipo, 'gn, 'pn, [> `Registrable ])
                    service
(** Same as [new_post_service] followed by [register] *)

    val register_new_post_coservice :
        fallback:('get, unit , 
                  [ `Attached of 
                    [ `Internal of [< `Service | `Coservice ] * [`Get] ] a_s ],
                   [< suff ] as 'tipo, 
                   'gn, unit param_name, [< `Registrable ])
        service ->
          post_params:('post, [ `WithoutSuffix ], 'pn) params_type ->
            ?error_handler:(server_params -> (string * exn) list -> 
              page Lwt.t) ->
                (server_params -> 'get -> 'post -> page Lwt.t) ->
                  ('get, 'post, 
                   [> `Attached of 
                     [> `Internal of [> `Coservice ] * [> `Post] ] a_s ], 
                     'tipo, 'gn, 'pn, [> `Registrable ])
                    service
(** Same as [new_post_coservice] followed by [register] *)

    val register_new_post_coservice' :
        post_params:('post, [ `WithoutSuffix ], 'pn) params_type ->
          ?error_handler:(server_params -> (string * exn) list -> 
            page Lwt.t) ->
              (server_params -> unit -> 'post -> page Lwt.t) ->
                (unit, 'post, [> `Nonattached of [> `Post] na_s ], 
                 [ `WithoutSuffix ], unit param_name, 'pn,
                 [> `Registrable ])
                  service
(** Same as [new_post_coservice'] followed by [register] *)

(*
    val register_new_get_post_coservice' :
        fallback:('get, unit , 
                  [ `Nonattached of [`Get] na_s ],
                   [< suff ] as 'tipo, 
                   'gn, unit param_name, [< `Registrable ])
        service ->
          post_params:('post, [ `WithoutSuffix ], 'pn) params_type ->
            ?error_handler:(server_params -> (string * exn) list -> 
              page Lwt.t) ->
                (server_params -> 'get -> 'post -> page Lwt.t) ->
                  ('get, 'post, [> `Nonattached of [> `Post] na_s ], 
                   [> 'tipo], 'gn, 'pn, [> `Registrable ])
                    service
(* * Same as [new_get_post_coservice'] followed by [register] *)
*)

    val register_new_post_coservice_for_session :
        server_params ->
          fallback:('get, unit, 
                    [< `Attached of [< `Internal of
                      [< `Service | `Coservice ] * [`Get] ] a_s ],
                    [< suff ] as 'tipo, 
                    'gn, unit param_name, [< `Registrable ])
            service ->
              post_params:('post, [ `WithoutSuffix ], 'pn) params_type ->
                ?error_handler:(server_params -> 
                  (string * exn) list -> page Lwt.t) ->
                    (server_params -> 'get -> 'post -> page Lwt.t) ->
                      ('get, 'post, 
                       [> `Attached of 
                         [> `Internal of [> `Coservice ] * [> `Post]] a_s ], 
                       'tipo, 'gn, 'pn, [> `Registrable ])
                        service
(** Same as [new_post_coservice] followed by [register_for_session] *)

    val register_new_post_coservice_for_session' :
        server_params ->
          post_params:('post, [ `WithoutSuffix ], 'pn) params_type ->
            ?error_handler:(server_params -> 
              (string * exn) list -> page Lwt.t) ->
                (server_params -> unit -> 'post -> page Lwt.t) ->
                  (unit, 'post, [> `Nonattached of [> `Post] na_s ], 
                   [ `WithoutSuffix ], unit param_name, 'pn, 
                   [> `Registrable ])
                    service
(** Same as [new_post_coservice'] followed by [register_for_session] *)

(*
    val register_new_get_post_coservice_for_session' :
        server_params ->
          fallback:('get, unit, [ `Nonattached of [`Get] na_s ],
                    [< suff ] as 'tipo, 
                    'gn, unit param_name, [< `Registrable ])
            service ->
              post_params:('post, [ `WithoutSuffix ], 'pn) params_type ->
                ?error_handler:(server_params -> 
                  (string * exn) list -> page Lwt.t) ->
                    (server_params -> 'get -> 'post -> page Lwt.t) ->
                      ('get, 'post, [> `NonAttached of [> `Post] na_s ], 
                       'tipo, 'gn, 'pn, [> `Registrable ])
                        service
(* * Same as [new_get_post_coservice] followed by [register_for_session] *)
*)



  end



module type ELIOMSIG = sig
  include ELIOMREGSIG
  include ELIOMFORMSIG
end



module MakeRegister : functor (Pages: REGCREATE) -> ELIOMREGSIG with 
type page = Pages.page

module MakeForms : functor (Pages: FORMCREATE) -> ELIOMFORMSIG with 
type form_content_elt = Pages.form_content_elt
and type form_content_elt_list = Pages.form_content_elt_list
and type form_elt = Pages.form_elt
and type a_content_elt = Pages.a_content_elt
and type a_content_elt_list = Pages.a_content_elt_list
and type a_elt = Pages.a_elt
and type a_elt_list = Pages.a_elt_list
and type div_content_elt = Pages.div_content_elt
and type div_content_elt_list = Pages.div_content_elt_list
and type uri = Pages.uri
and type link_elt = Pages.link_elt
and type script_elt = Pages.script_elt
and type textarea_elt = Pages.textarea_elt
and type select_elt = Pages.select_elt
and type input_elt = Pages.input_elt
and type pcdata_elt = Pages.pcdata_elt
and type a_attrib_t = Pages.a_attrib_t
and type form_attrib_t = Pages.form_attrib_t
and type input_attrib_t = Pages.input_attrib_t
and type textarea_attrib_t = Pages.textarea_attrib_t
and type select_attrib_t = Pages.select_attrib_t
and type link_attrib_t = Pages.link_attrib_t
and type script_attrib_t = Pages.script_attrib_t
and type input_type_t = Pages.input_type_t

(** {2 Pages registration (typed xhtml)} *)
module Xhtml : sig

  include ELIOMREGSIG with type page = xhtml elt

(** {2 Creating links, forms, etc.} *)

  val a :
      ?a:a_attrib attrib list ->
        ('get, unit, [< get_service_kind ], 
         [< suff ], 'gn, unit param_name,
         [< registrable ]) service ->
           server_params -> a_content elt list -> 'get -> [> a] XHTML.M.elt
(** [a service sp cont ()] creates a link from [current] to [service]. 
   The text of
   the link is [cont]. For example [cont] may be something like
   [\[pcdata "click here"\]]. 

   The last  parameter is for GET parameters.
   For example [a service sp cont (42,"hello")]

   The [~a] optional parameter is used for extra attributes 
   (see the module XHTML.M) *)

  val css_link : ?a:(link_attrib attrib list) ->
    uri -> [> link ] elt
(** Creates a [<link>] tag for a Cascading StyleSheet (CSS). *)

  val js_script : ?a:(script_attrib attrib list) ->
    uri -> [> script ] elt
(** Creates a [<script>] tag to add a javascript file *)

    val make_uri :
        ('get, unit, [< get_service_kind ],
         [< suff ], 'gn, unit param_name, 
         [< registrable ]) service ->
          server_params -> 'get -> uri
(** Create the text of the service. Like the [a] function, it may take
   extra parameters. *)


    val get_form :
        ?a:form_attrib attrib list ->
          ('get, unit, [< get_service_kind ],
           [<suff ], 'gn, unit param_name, 
           [< registrable ]) service ->
             server_params ->
              ('gn -> form_content elt list) -> [>form] elt
(** [get_form service current formgen] creates a GET form from [current] to [service]. 
   The content of
   the form is generated by the function [formgen], that takes the names
   of page parameters as parameters. *)

    val post_form :
        ?a:form_attrib attrib list ->
          ('get, 'post, [< post_service_kind ],
           [< suff ], 'gn, 'pn, 
           [< registrable ]) service ->
            server_params ->
              ('pn -> form_content elt list) -> 'get -> [>form] elt
(** [post_form service current formgen] creates a POST form from [current] 
   to [service]. The last parameter is for GET parameters (as in the function [a]).
 *)

(*
   val img : ?a:(img_attrib attrib list) ->
   alt:string ->
   ('a, form_content elt list, 'ca,'cform, 'curi, 'd, 'e, 'f, 'g) service -> server_params -> 'cimg
 *)

  val int_input : ?a:(input_attrib attrib list ) -> 
    ?value:int ->
    int param_name -> [> input ] elt
(** Creates an [<input>] tag for an integer *)

  val float_input : ?a:(input_attrib attrib list ) -> 
    ?value:float ->
    float param_name -> [> input ] elt
(** Creates an [<input>] tag for a float *)

  val string_input : 
      ?a:(input_attrib attrib list ) -> 
        ?value:string ->
          string param_name -> [> input ] elt
(** Creates an [<input>] tag for a string *)

  val user_type_input : 
      ?a:(input_attrib attrib list ) -> 
        ?value:'a ->
          ('a -> string) ->
            'a param_name -> 
              [> input ] elt
(** Creates an [<input>] tag for a user type *)

  val int_password_input : ?a:(input_attrib attrib list ) -> 
    ?value:int ->
    int param_name -> [> input ] elt
(** Creates an [<input type="password">] tag for an integer *)

  val float_password_input : ?a:(input_attrib attrib list ) -> 
    ?value:float ->
    float param_name -> [> input ] elt
(** Creates an [<input type="password">] tag for a float *)

  val string_password_input : 
      ?a:(input_attrib attrib list ) -> 
        ?value:string ->
          string param_name -> [> input ] elt
(** Creates an [<input type="password">] tag for a string *)

  val user_type_password_input : 
      ?a:(input_attrib attrib list ) -> 
        ?value:'a ->
          ('a -> string) ->
            'a param_name -> 
              [> input ] elt
(** Creates an [<input type="password">] tag for a user type *)

  val hidden_int_input : 
      ?a:(input_attrib attrib list ) -> 
        int param_name -> int -> [> input ] elt
(** Creates an hidden [<input>] tag for an integer *)

  val hidden_float_input : 
      ?a:(input_attrib attrib list ) -> 
        float param_name -> float -> [> input ] elt
(** Creates an hidden [<input>] tag for a float *)

  val hidden_string_input : 
      ?a:(input_attrib attrib list ) -> 
        string param_name -> string -> [> input ] elt
(** Creates an hidden [<input>] tag for a string *)

  val hidden_user_type_input : 
      ?a:(input_attrib attrib list ) -> ('a -> string) ->
        'a param_name -> 'a -> [> input ] elt
(** Creates an hidden [<input>] tag for a user type *)

  val bool_checkbox :
      ?a:(input_attrib attrib list ) -> ?checked:bool -> 
        bool param_name -> [> input ] elt
(** Creates a checkbox [<input>] tag *)

  val string_radio : ?a:(input_attrib attrib list ) -> ?checked:bool -> 
    string option param_name -> string -> [> input ] elt
(** Creates a radio [<input>] tag with string content *)
  val int_radio : ?a:(input_attrib attrib list ) -> ?checked:bool -> 
     int option param_name -> int -> [> input ] elt
(** Creates a radio [<input>] tag with int content *)
  val float_radio : ?a:(input_attrib attrib list ) -> ?checked:bool -> 
     float option param_name -> float -> [> input ] elt
(** Creates a radio [<input>] tag with float content *)
  val user_type_radio : ?a:(input_attrib attrib list ) -> ?checked:bool ->
    ('a -> string) -> 'a option param_name -> 'a -> [> input ] elt
(** Creates a radio [<input>] tag with user_type content *)

  val textarea : ?a:(textarea_attrib attrib list ) -> 
    string param_name -> rows:number -> cols:number -> [ `PCDATA ] XHTML.M.elt ->
      [> textarea ] elt
(** Creates a [<textarea>] tag *)

  val select : ?a:(select_attrib attrib list ) ->
    ?selected:((string option * string) option)
    -> (string option * string) -> ((string option * string) list) ->
    string param_name
    -> [> select ] elt
(** Basic support for the [<select>] tag.

The associated parameter is of type "string". It is used in forms as for 
example:

[select (None, "inconnue") [(None, "C1"); (None, "C2")] classe]


where "classe" is the parameter name. The different choices are of the form
[(<optional string1>, <string2>)]. "string2" is presented to the user and 
if selected it is the returned value except when "string1" is present 
(where it is "string1"). It is modeled after the way "select" is done in 
HTML.

Not all features of "select" are implemented.
 *)

  val submit_input : ?a:(input_attrib attrib list ) -> 
    string -> [> input ] elt
(** Creates a submit [<input>] tag *)

  val file_input : ?a:(input_attrib attrib list ) ->
    ?value:string -> file_info param_name -> [> input ] elt


end

module Text : ELIOMSIG with 
type page = string
and type form_content_elt = string
and type form_content_elt_list = string
and type form_elt = string 
and type a_content_elt = string 
and type a_content_elt_list = string 
and type a_elt = string 
and type a_elt_list = string 
and type div_content_elt = string 
and type div_content_elt_list = string 
and type uri = string 
and type link_elt = string 
and type script_elt = string 
and type textarea_elt = string 
and type select_elt = string 
and type input_elt = string 
and type pcdata_elt = string 
and type a_attrib_t = string 
and type form_attrib_t = string 
and type input_attrib_t = string 
and type textarea_attrib_t = string 
and type select_attrib_t = string 
and type link_attrib_t = string 
and type script_attrib_t = string 
and type input_type_t = string 


module Actions : ELIOMREGSIG with 
  type page = exn list

module Unit : ELIOMREGSIG with 
  type page = unit
