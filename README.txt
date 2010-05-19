1) Code up the export & import function for a couple fileformat
2) Iterate the version to 0.2 and add in versoning support
3) Figure out why the icons are not working on the work-computer

4) Fix this - New database - open calendar dialog
/usr/lib/ruby/1.8/date.rb:956:in `new_by_frags': invalid date
	from /usr/lib/ruby/1.8/date.rb:1000:in `parse'
	from ./work_view.rb:94:in `on_button'
	from ./work_view.rb:47:in `initialize'
	from ./main.rb:21:in `call'
	from ./main.rb:21:in `main'
	from ./main.rb:21

5) Fix the dialog/calendar dropdown creating a new window on the taskbar

6) Fix this - No config file anywhere:
Loading: 
./controller.rb:31:in `load': no such file to load -- .rb (LoadError)
	from ./controller.rb:31:in `initialize'
	from ./main.rb:14:in `new'
	from ./main.rb:14

7) Add in edge checks on writing out the config, such as cannot write to the
file and so forth

8) Figure out how to deal with more than 1 file type, esp for "new" db, and
probably spend some time cleaning up the controller/API a bit to seperate out
the santize_filename function into two function, one for creating and one for
opening databases
