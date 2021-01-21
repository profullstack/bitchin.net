module main

import vweb
import os
import zztkm.vdotenv
import json

struct App {
	vweb.Context

	mut: 
		db string
		emails string
		port int
}

struct Items {
	items []Item
}

struct Item {
	name string
	link string
  tags []string
}


fn main() {
	vdotenv.load()
	mut app := App{}
	app.port = os.getenv('PORT').int()
	app.db = os.getenv('DB_FILE')
	app.emails = os.getenv('EMAILS_FILE')

	println('bitchin.net')
	println(app.db)
	vweb.run_app<App>(mut app, app.port)
}

pub fn(mut app App) init_once() {
		app.set_app_static_mappings()
}

fn (mut app App) set_app_static_mappings() {
	app.handle_static('public')
}

pub fn (mut app App) unsubscribe() vweb.Result {
	email := app.query['email']
	mut emails := os.read_lines(app.emails) or { panic(err) }
	idx := emails.index(email)
	println(emails)
	println(idx)

	if idx > -1 {
		emails.delete(idx)
	}

	println(emails)
	write_file(app.emails, emails.join('\n')) or { panic(err) }

	return app.json('{"status": "ok", "email": "$email"}')
}

pub fn (mut app App) subscribe() vweb.Result {
	email := app.query['email']
	mut emails := os.read_lines(app.emails) or { panic(err) }
	emails << email
	println(emails)

	write_file(app.emails, emails.join('\n')) or { panic(err) }

	return app.json('{"status": "ok", "email": "$email"}')
}

pub fn (mut app App) index() vweb.Result {
	text := os.read_file(app.db) or { panic(err) }
	items := json.decode([]Item, text) or { panic(err) }
	return $vweb.html()
}
