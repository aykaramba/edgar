EDGAR is a a self learning project to help me learn how to program in Common Lisp using the CLOG user interface toolkit.  


This project is an attempt to build a GUI for the the following tutorials my MURO: <a href="https://medium.com/@codingcamel/extracting-fundamental-stock-data-from-edgar-using-our-favorite-language-common-lisp-part-1-a3171d100dd4" target="_blank">Tutorial #1</a>, <a href="https://medium.com/@codingcamel/extracting-fundamental-stock-data-from-edgar-using-our-favorite-language-common-lisp-part-2-f28099de4b71" target="_blank">Tutorial #2</a> and <a href="https://medium.com/@codingcamel/extracting-fundamental-stock-data-from-edgar-using-our-favorite-language-common-lisp-part-3-5ea58d903b97" target="_blank">Tutorial #3.</a>


The three tutorials (hopefully more to come) show how to download data from the SEC public filings database called EDGAR, convert the JSON file (DEX format) to something easy to work with using cl-json, do some parsing and then extract some interesting information.  I thought this simple to follow tutorial would be a great opportunity to learn the basics of programming by creating a trivial web interface using the <a href="https://github.com/rabbibotton/clog" target="_blank">CLOG</a> ui framework.

This project is also inspired by:

1) This Common Lisp course I am taking on Udemy by  <a href="https://www.udemy.com/course/common-lisp-programming/" target="_blank">Vincent Dardel</a>.  

2) The Common Lisp tutorials provided by the creator of CLOG, <a href="https://github.com/rabbibotton/clog/blob/main/LEARN.md" target="_blank">David Botton</a>.


**SCREENSHOTS**

1) Paginated view of companies - Category C - Page 57:
![01](https://github.com/aykaramba/edgar/assets/16431651/eb5df31e-0721-40a6-9222-b54b21826feb)

  

2) Paginated view of companies - Category C - Page 27 - With notifications popup to check variable values:
![02](https://github.com/aykaramba/edgar/assets/16431651/5686cc5d-3802-4dfa-93c2-90ca28c6b8b5)



3) Download view of datasets - No usual sort / delete features, just a simple display of datasets in the db, dates, table name, local file copies, etc.:
![03](https://github.com/aykaramba/edgar/assets/16431651/a36be90d-8dba-4f1d-bf53-1f575151df93)



4) Help view - The view is dynamically created from two text files using the cl-markdown library:
![04](https://github.com/aykaramba/edgar/assets/16431651/977652ba-c7d8-4c3f-aced-a0f9654cc00c)




**INSTALLATION**

1) Git clone the repo to your ~/quicklisp/local-projects or ~/common list folders.  

2) Using the LEM editor:  
a) M-x start-lisp-repl  
b) In repl: (ql:quickload :edgar)  
c) In repl: (edgar:start-app)  
d) Accessible via: http://localhost:8080  

2) Using Emacs:

a) SPECIAL NOTE:  I created a component for the LEM editor as part of the Edgar project to reload the CLOG instance running in the browser using C-v.  This does not work in Emacs as I did not create cross-editor compatability for this component.  It really should be removed from EDGAR and into LEM it self.  If you load EDGAR in Emacs, the compiler will complain, just accept the error and it will start and work normally minus the C-v shortcut.  
b) M-x start-slime or M-x start-sly   
c) In repl: (ql:quickload :edgar)  
d) In repl: (edgar:start-app)   
e) Ignore the compiler complaint and continue.  
f) Accessible via: http://localhost:8080  

**Key design goeals and features:**

* The application is discovered, not engineered.  I am learning programming, I wanted to explore instead of engineer what is possible.
* The entire app is poorly constructed in a non-functional style with a ton of side effects.  Changing code is quite fragile with many edge cases manually patched instead of engineered.  The app is already begging for a refactor with a properly engineered architecture.
* It is an SPA (single page application).  This deliberately breaks the browser convention of traversing url paths because I wanted to explore what it means to create a single page application using CLOG.
* It provides the following views: Paginated list of companies, list of downloaded DEX files from the SEC, a notifications window that gives me a real time view of variable values used in the app and a help view that you are reading here.
* The SPA provides the ability to download the EDGAR DEX file from the SEC following their rules and requirements (as per tutorial), converts the json file and stores the data in a table in an Sqlite database.  
* I tried to communicate to the user the minimum amount of ui state notifications necessasry to let the user know what paginated view they are on, provide notifications during mouse overs for the ui as well as provide minimal interface feedback to the user while the db is locked.  The notifications popup also allows a user to click through the interface and see the value of each variable in the app being changed, which was helpful to me during the debugging process.
* This HELP view is also dynamically generated from two text files using the cl-markdown package.

**Special notes:** 

I used the <a href="https://github.com/lem-project/lem" target="_blank">LEM</a> editor to write EDGAR and created quality of life binding that loads up with EDGAR in order to let me reload the app with the following shortcut: C-v.  One of the frustrating parts of iterative learning + development in a web app is the infinite need to take your hand off of the keyboard and use the mouse to hunt and peck the reload button in a browser or use a timed page reload extension to see your changes.  The repetitive nature of this process starts to grate on the nerves very quickly and this QOL feature allows me to C-c to compile a single form and then  C-v to have CLOG reload the browser so I can see my changes.  Of course, this feature does not belong in EDGAR, it belongs in the editor as part of LEMs project management facility.  I will extend that later when I learn more, for now this is a fun way to provide a per project editor extension and I may extend this concept in the future to provide more complex interactions with my CLOG apps directly from LEM.

I have also developed an indentation style that I call "chopshop" designed to let me use the core Paredit functionality to copy / paste forms around the program with ease and let me visualize the hierarchical structure of the code in a way that the standard Common Lisp coding style does not allow.  I have discovered that I can also use this indentation style with languages that use infix notation in order to make them easier to understand and visualize.  When I started learning Lisp, I found it extremely difficult to see where one form ended and another began.  Eventually I just had to give up on the default indentation style becuase it was virtually impenetrable visually. Instead, the "chopshop" approach to let me chop + paste bits of code around has made the whole process of programming fun and aboslutely interesting.  I have to confess that this has been my first programming experience that I actually enjoyed, and I looked forward to every day that I could get into the code, mess about and make stuff happen.  Of course, CLOG and LEM are majour components of that feedback loop and the tasteful selection of W3.CSS as the css framework for CLOG makes the whole experiencet that much more fun to explore.

**Is there a future for EDGAR?**  

My initial goal with EDGAR is to learn to program by creating a user interface for MURO's 3 tutorials, this is done.  The next step is to add some of the following functionality:

* Delete downloaded datasets.
* Allow users to click on a company and drill down into the financials of each company to analyse things like earnings per share, etc.  
* Allow users to click on a company and generate graphs and visualizations of various financial data.
* Add a search feature.
* Add a home button, reposition the reload button.
* Create a control panel for managing users, per user permissions and sign up / log in forms.

My long term goal is to build a tool that I can point at a REST interface, consume JSON data and create interfaces to glue different systems together. Chances are that I will need to custom build those interfaces manually, however, perhaps EDGAR can be a platform for deploying those glue interfaces. Certainly, I foresee a tremendous amount of graphing and visualization capability that will need to be built and EDGAR may end up growing a lot of Business Intelligence (BI) style features as well.


 
