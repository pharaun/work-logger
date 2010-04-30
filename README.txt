1) Code up the export & import function for a couple fileformat
2) Iterate the version to 0.2 and add in versoning support
3) Add in config file support so it will open the last open database
4) Figure out why the icons are not working on the work-computer

5) Fix this - New database - open calendar dialog
/usr/lib/ruby/1.8/date.rb:956:in `new_by_frags': invalid date
	from /usr/lib/ruby/1.8/date.rb:1000:in `parse'
	from ./work_view.rb:94:in `on_button'
	from ./work_view.rb:47:in `initialize'
	from ./main.rb:21:in `call'
	from ./main.rb:21:in `main'
	from ./main.rb:21

6) Fix the dialog/calendar dropdown creating a new window on the taskbar
7) Add "support" for registering config change listeners into Work::Config

8) Fix this - No config file anywhere:
Loading: 
./controller.rb:31:in `load': no such file to load -- .rb (LoadError)
	from ./controller.rb:31:in `initialize'
	from ./main.rb:14:in `new'
	from ./main.rb:14
