%% Tutorial for xml_io_tools Package
% *By Jarek Tuszynski*
%
% Package xml_io_tools can read XML files into MATLAB struct and writes 
% MATLAB data types to XML files with help of simple interface to 
% MATLAB's xmlwrite and xmlread functions.
% 
% Two function to simplify reading and writing XML files from MATLAB:
%
% * Function xml_read first calls MATLAB's xmlread function and than 
% converts its output ('Document Object Model' tree of Java objects) 
% to tree of MATLAB struct's. The output is in the format of nested 
% structs and cells. In the output data structure field names are based on
% XML tags.
%
% * Function xml_write first convert input tree of MATLAB structs and cells 
% and other types to tree of 'Document Object Model' nodes, and then writes 
% resulting object to XML file using MATLAB's xmlwrite function. .
%
%% This package can:
% * Read most XML files, created inside and outside of MATLAB, and 
%   convert them to MATLAB data structures.
% * Write any MATLAB's struct tree to XML file
% * Handle XML attributes in the same way as xml_toolbox package
% * Handle special XML nodes like comments, processing instructions and 
%   CDATA sections
% * Be studied, modified, customized, rewritten and used in other packages 
%   without any limitations. All code is included and documented. Software
%   is distributed under MIT Licence (included).   
%
%% This package does not:
% * Guarantee to recover the same Matlab objects that were saved. If you 
% need to be able to recover carbon copy of the structure that was saved 
% than you will have to use one of the packages that uses special set of 
% tags saved as xml attributes that help to guide the parsing of XML code. 
% This package does not do that.
% * Guarantee to work with older versions of MATLAB. Functions do not work
% with versions of MATLAB prior to 7.1 (26-Jul-2005). Versions starting 
% with 7.1 seem to work on my machine, which have current java engine and 
% libraries. 
%
%% Change History
% * 2006-11-06 - original version
% * 2006-11-26 - corrected xml_write to handle writing Matlab's column
%   arrays to xml files. Bug discovered and diagnosed by Kalyan Dutta.
% * 2006-11-28 - made changes to handle special node types like: 
%   COMMENTS and CDATA sections 
% * 2007-02-20 - Writing CDATA sections still did not worked. The problem 
%   was diagnosed and fixed by Alberto Amaro. The fix involved rewriting
%   xmlwrite to use Apache Xerces java files directly instead of MATLAB's 
%   XMLUtils java class.
% * 2007-06-20 - Fixed problem reported by Anna Kelbert in Reviews about 
%   not writing attributes of ROOT node. Also: added support for Processing
%   Instructions, added support for global text nodes: Processing
%   Instructions and comments, allowed writing tag names with special
%   characters
% * 2007-07-19 - Added tutorial script file. Extended support for global
%   text nodes. Added more Preference fields.
% * 2008-01-05 - Fixed problem reported by Anna Krewet of converting dates 
%   in format '2007-01-01' to numbers. Improved and added warning messages.
%   Added detection of old Matlab versions incompatible with the library.
%   Expanded documentation.
%% Licence
% The package is distributed under MIT Licence
format compact; % viewing preference
clear variables;
type('MIT_Licence.txt')

%% Write XML file based on a Struct using "xml_write"
% Any MATLAB data struct can be saved to XML file. Notice that
% 'tree' only defines content of the root element. Its name has to be
% either passed separately or deduced from the input variable name.
MyTree=[];
MyTree.MyNumber = 13;
MyTree.MyString = 'Hello World';
xml_write('test.xml', MyTree);
type('test.xml')

%% Read XML file producing a Struct using "xml_read"
[tree treeName] = xml_read ('test.xml');
disp([treeName ' ='])
gen_object_display(tree)

%% "Pref.XmlEngine" flag in "xml_write"
% Same operation using Apache Xerces XML engine. Notice that in this case root element name
% was passed as variable and not extracted from the variable name.
Pref=[]; Pref.XmlEngine = 'Xerces';  % use Xerces xml generator directly
xml_write('test.xml', MyTree, 'TreeOfMine', Pref);
type('test.xml')

%% "Pref.StructItem" flag in "xml_write"
% *Create a simple structure with arrays of struct's*
MyTree = [];
MyTree.a(1).b = 'jack';
MyTree.a(2).b = 'john';
gen_object_display(MyTree)
%%
% *Write XML with "StructItem = true" (default).  Notice single 'a' 
% section and multiple 'item' sub-sections. Those subsections are used 
% to store array elements*
wPref.StructItem = true;
xml_write('test.xml', MyTree, 'MyTree',wPref);
type('test.xml')
fprintf('\nxml_read output:\n')
gen_object_display(xml_read ('test.xml'))
%%
% *Write XML with "StructItem = false". Notice multiple 'a' sections*
wPref.StructItem = false;
xml_write('test.xml', MyTree, 'MyTree',wPref);
type('test.xml')
fprintf('\nxml_read output:\n')
gen_object_display(xml_read ('test.xml'))
%%
% *Notice that xml_read function produced the same struct when reading both files*
%%
% *Potential problems with "StructItem = true":*
wPref.StructItem = true;
MyTree1 = []; MyTree1.a.b    = 'jack';
MyTree2 = []; MyTree2.a(1).b = 'jack';
MyTree3 = []; MyTree3.a(2).b = 'jack';
xml_write('test.xml', MyTree1, [], wPref); type('test.xml');
xml_write('test.xml', MyTree2, [], wPref); type('test.xml');
xml_write('test.xml', MyTree3, [], wPref); type('test.xml');
%%
% *Notice that MyTree1 and MyTree2 produce identical files with no 'items',
% while MyTree2 and MyTree3 produce very different file structures. It was
% pointed out to me that files produced from MyTree2 and MyTree3 can not 
% belong to the same schema, which can be a problem.* 


%% "Pref.CellItem" flag in "xml_write"
% *Create a simple structure with cell arrays*
MyTree = [];
MyTree.a = {'jack', 'john'};
disp(MyTree)
%%
% *Write XML with "StructItem = true" (default).  Notice single 'a' 
% section and multiple 'item' sections*
Pref=[]; Pref.CellItem = true;
xml_write('test.xml', MyTree, 'MyTree',Pref);
type('test.xml')
fprintf('\nxml_read output:\n');
disp(xml_read ('test.xml'))
%%
% *Write XML with "StructItem = false". Notice multiple 'a' sections*
Pref=[]; Pref.CellItem = false;
xml_write('test.xml', MyTree, 'MyTree',Pref);
type('test.xml')
fprintf('\nxml_read output:\n');
disp(xml_read ('test.xml'))
%%
% *Notice that xml_read function produced the same struct when reading both files*


%% "Pref.NoCells" flag in "xml_read"
% *Create a cell/struct mixture object*
MyTree = [];
MyTree.a{1}.b = 'jack';
MyTree.a{2}.b = [];
MyTree.a{2}.c = 'john';
gen_object_display(MyTree);
%%
% *Save it to xml file*
Pref=[]; Pref.CellItem = false;
xml_write('test.xml', MyTree, 'MyTree',Pref);
type('test.xml')
%%
% *Read above file with "Pref.NoCells=true" (default) - output is quite different then input*
% By default program is trying to convert everything to struct's and arrays
% of structs. In case arrays of structs all the structs in array need to have the
% same fields, and if they are not than MATLAB creates empty fields.
Pref=[]; Pref.NoCells=true;
gen_object_display(xml_read('test.xml', Pref))
%%
% *Read above file with "Pref.NoCells=false" - now input and output are the same*
% Cell arrays of structs allow structs in array to have different fields.
Pref=[]; Pref.NoCells=false;
gen_object_display(xml_read('test.xml', Pref))

%% "Pref.ItemName" flag in "xml_write"
% *Create a cell/struct mixture object*
MyTree = [];
MyTree.a{1}.b = 'jack';
MyTree.a{2}.c = 'john';
gen_object_display(MyTree);
%%
% *Save it to xml file, using 'item' notation but with different name*
Pref=[]; 
Pref.CellItem = true;
Pref.ItemName = 'MyItem';
xml_write('test.xml', MyTree, 'MyTree',Pref);
type('test.xml')

%% "Pref.ItemName" flag in "xml_read"
% *Read above file with default settings ("Pref.ItemName = 'item'")*
% The results do not match the original structure
Pref=[]; Pref.NoCells  = false;
gen_object_display(xml_read('test.xml', Pref))
%%
% *Read above file with "Pref.ItemName = 'MyItem'" - now saved and read 
% MATLAB structures are the same*
Pref=[]; 
Pref.ItemName = 'MyItem';
Pref.NoCells  = false;
gen_object_display(xml_read('test.xml', Pref))


%% "Pref.Str2Num" flag in xml_read
% *Create a cell/struct mixture object*
MyTree = [];
MyTree.str     = 'sphere';
MyTree.num1    =  123;
MyTree.num2    = '123';
MyTree.complex = 1 + 2i;
MyTree.calc    = '1+2+3+4';
MyTree.func    = 'sin(pi)/2';
MyTree.date    = '01-20-2007';
gen_object_display(MyTree);
%%
% *Save it to xml file, using 'item' notation but with different name*
xml_write('test.xml', MyTree);
type('test.xml')
%%
% *Read above file with default settings ("Pref.Str2Num = true")*
% This option 
gen_object_display(xml_read('test.xml'))
%%
% *Note that all the fields of 'MyTree' can be converted to numbers (even 
% 'sphere') but the function is trying to 'judge' if a string should be 
% converted to a number or not*
MyCell = {'sphere','123','1 + 2i','1+2+3+4', 'sin(pi)/2', '01-20-2007'};
cellfun(@str2num, MyCell, 'UniformOutput', false)
%%
% *Read above file with "Pref.Str2Num = false"* to keep all the fields in
% string format*
Pref=[]; 
Pref.Str2Num = false;
gen_object_display(xml_read('test.xml', Pref))
%%
% *Notice that both settings will produce the same output for "num1" and
% "num2" and there is no way to reproduce the original "MyTree" structure.*

%% Write XML files with ATTRIBUTEs 
% In order to add node attributes a special ATTRIBUTE and CONTENT fields 
% are used.
MyTree=[];
MyTree.MyNumber = 13;
MyTree.MyString.CONTENT = 'Hello World';
MyTree.MyString.ATTRIBUTE.Num = 2;
xml_write('test.xml', MyTree);
type('test.xml')
%%
% *Same operation using Apache Xerces XML engine*
Pref=[]; Pref.XmlEngine = 'Xerces';  % use Xerces xml generator directly
xml_write('test.xml', MyTree, [], Pref);
type('test.xml')

%% Write XML files with COMMENTs
% Insertion of Comments is done with help of special COMMENT field.
% Note that MATLAB's xmlwrite is less readable due to lack of end-of-line 
% characters around comment section. 
MyTree=[];
MyTree.COMMENT = 'This is a comment';
MyTree.MyNumber = 13;
MyTree.MyString.CONTENT = 'Hello World';
xml_write('test.xml', MyTree);
type('test.xml')
%%
% *Same operation using Apache Xerces XML engine*
% gives the same result
Pref=[]; Pref.XmlEngine = 'Xerces';  % use Xerces xml generator directly
xml_write('test.xml', MyTree, 'MyTree', Pref);
type('test.xml')

%%
% *Comments in XML top level (method #1)*
% This method uses cell array 
MyTree=[];
MyTree.MyNumber = 13;
MyTree.MyString = 'Hello World';
xml_write('test.xml', MyTree, {'MyTree', [], 'This is a global comment'});
type('test.xml')
%%
% *Same operation using Apache Xerces XML engine* 
% gives even nicer results.
Pref=[]; Pref.XmlEngine = 'Xerces';  % use Xerces xml generator directly
xml_write('test.xml', MyTree, {'MyTree', [], 'This is a global comment'}, Pref);
type('test.xml')

%%
% *Comments in XML top level (method #2)*
% This method adds an extra top layer to the struct 'tree' and sets
% "Pref.RootOnly = false", which informs the function about the extra 
% layer. Notice that RootName is also saved as a part of
% the 'tree', and does not have to be passed in separately.
MyTree=[];
MyTree.COMMENT = 'This is a global comment';
MyTree.MyTest.MyNumber = 13;
MyTree.MyTest.MyString = 'Hello World';
Pref=[]; Pref.RootOnly = false;
xml_write('test.xml', MyTree, [], Pref);
type('test.xml')
%%
% *Same operation using Apache Xerces XML engine*
Pref=[]; 
Pref.XmlEngine = 'Xerces';  % use Xerces xml generator directly
Pref.RootOnly  = false;
xml_write('test.xml', MyTree, [], Pref);
type('test.xml')

%% Write XML files with PROCESSING_INSTRUCTIONs 
% Insertion of Processing Instructions is done through use of special 
% PROCESSING_INSTRUCTION field, which stores the instruction string. The
% string has to be in 'target data' format separated by space.
MyTree=[];
MyTree.PROCESSING_INSTRUCTION = 'xml-stylesheet type="a" href="foo"';
MyTree.MyNumber = 13;
MyTree.MyString = 'Hello World';
xml_write('test.xml', MyTree);
type('test.xml')

%%
% *Same operation using Apache Xerces XML engine*
Pref=[]; Pref.XmlEngine = 'Xerces';  % use Xerces xml generator directly
xml_write('test.xml', MyTree, 'MyTree', Pref);
type('test.xml')

%%
% *PROCESSING_INSTRUCTIONs in XML top level (method #1)*
% This method uses cell array 
MyTree=[];
MyTree.MyNumber = 13;
MyTree.MyString = 'Hello World';
xml_write('test.xml', MyTree, {'MyTree', 'xml-stylesheet type="a" href="foo"'});
type('test.xml')
%%
% *Same operation using Apache Xerces XML engine*
Pref=[]; Pref.XmlEngine = 'Xerces';  % use Xerces xml generator directly
xml_write('test.xml', MyTree, {'MyTree', 'xml-stylesheet type="a" href="foo"'}, Pref);
type('test.xml')

%%
% *PROCESSING_INSTRUCTIONs in XML top level (method #2)*
% This method adds an extra top layer to the struct 'tree' and sets
% pref.RootOnly=false, which informs the function about the extra 
% layer. Notice that RootName is also saved as a part of
% the 'tree', and does not have to be passed in separately.
MyTree=[];
MyTree.PROCESSING_INSTRUCTION =  'xml-stylesheet type="a" href="foo"';
MyTree.MyTest.MyNumber = 13;
MyTree.MyTest.MyString = 'Hello World';
Pref=[]; Pref.RootOnly = false;
xml_write('test.xml', MyTree, [], Pref);
type('test.xml')
%%
% *Same operation using Apache Xerces XML engine*
Pref=[]; 
Pref.XmlEngine = 'Xerces';  % use Xerces xml generator directly
Pref.RootOnly  = false;
xml_write('test.xml', MyTree, 'MyTree', Pref);
type('test.xml')

%% Write XML files with CDATA Sections 
% "In an XML document a CDATA (Character DATA) section is a section of 
%  element content that is marked for the parser to interpret as only 
%  character data, not markup." (from Wikipedia) 
% To insert CDATA Sections one use special CDATA_SECTION field,
%  which stores the instruction string. Note that MATLAB's xmlwrite created
%  wrong xml code for CDATA section
MyTree=[];
MyTree.CDATA_SECTION = '<A>txt</A>';
MyTree.MyNumber = 13;
MyTree.MyString = 'Hello World';
xml_write('test.xml', MyTree);
type('test.xml')
%%
% *Same operation using Apache Xerces XML engine produces correct results*
Pref=[]; Pref.XmlEngine = 'Xerces';  % use Xerces xml generator directly
xml_write('test.xml', MyTree, 'MyTree', Pref);
type('test.xml')

%% Write XML files with special characters in TAG names
% The input to xml_write requires that all tags one wants in XML document 
% have to be encoded as field names of MATLAB's struct's. Matlab has a lot
% of restrictions on variable names. This section is about XML tags with
% names not allowed as MATLAB variables, or more specifically with
% characters allowed as xml tag names but not allowed as MATLAB variable
% names. Characters like that can be replaced by their hexadecimal
% representation just as it is done by genvarname function. Alternative way
% of writing the first example is:
MyTree=[];
MyTree.('MyNumber') = 13;               % same as MyTree.MyNumber = 13;
MyTree.MyString.CONTENT = 'Hello World';
MyTree.MyString.ATTRIBUTE.('Num') = 2;  % same as MyTree.MyString.ATTRIBUTE.Num = 2;
xml_write('test.xml', MyTree);
type('test.xml')

%%
% *This approach fails for some characters like dash '-', colon ':', and
% international characters.*
MyTree=[];
try
  MyTree.('My-Number') = 13;
  MyTree.MyString.CONTENT = 'Hello World';
  MyTree.MyString.ATTRIBUTE.('Num_�') = 2;
catch
  err = lasterror;
  disp(err.message);
end

%%
% It can be overcome by replacing offending characters with their 
% hexadecimal representation. That can be done manually or with use of 
% genvarname function. Note that MATLAB 'type' function does not show
% correctly '�' letter in xml file, but opening the file in editor shows 
% that it is correct.
MyTree=[];
MyTree.(genvarname('My-Number')) = 13;
MyTree.MyString.CONTENT = 'Hello World';
MyTree.MyString.ATTRIBUTE.Num_0xF6 = 2;
gen_object_display(MyTree);
xml_write('test.xml', MyTree);
type('test.xml')

%%
% *Also two of the characters '-' and ':' can be encoded by a special strings:
% '_DASH_' and '_COLON_' respectively*
MyTree=[];
MyTree.My_DASH_Number = 13;
MyTree.MyString.CONTENT = 'Hello World';
MyTree.MyString.ATTRIBUTE.Num0xF6 = 2;
xml_write('test.xml', MyTree);
type('test.xml')

%% Write XML files with Namespaces
% No extra special fields are needed to define XML namespaces, only colon 
% character written using '0x3A' or '_COLON_'. Below is an
% example of a namespace definition
MyTree=[];
MyTree.f_COLON_child.ATTRIBUTE.xmlns_COLON_f = 'http://www.foo.com';
MyTree.f_COLON_child.f_COLON_MyNumber = 13;
MyTree.f_COLON_child.f_COLON_MyString = 'Hello World';
xml_write('test.xml', MyTree, 'MyTree');
type('test.xml')
%%
% *Same operation using Apache Xerces XML engine*
Pref=[]; Pref.XmlEngine = 'Xerces';  % use Xerces xml generator directly
xml_write('test.xml', MyTree, 'f_COLON_MyTree', Pref);
type('test.xml')

%% 
% *Another example of namespaces which is handled differently by both xml writing 
% methods. Either I have created illegal configuration or both methods have bugs.*  
MyTree=[];
MyTree.ATTRIBUTE.xmlns_COLON_f = 'http://www.foo.com';
MyTree.f_COLON_MyNumber = 13;
MyTree.f_COLON_MyString = 'Hello World';
xml_write('test.xml', MyTree, 'f_COLON_MyTree');
type('test.xml')
%%
% *Same operation using Apache Xerces XML engine*
Pref=[]; Pref.XmlEngine = 'Xerces';  % use Xerces xml generator directly
xml_write('test.xml', MyTree, 'f_COLON_MyTree', Pref);
type('test.xml')


%% Read XML files with special node types
% Display and read the file, then show the data structure. Note that 
% MATLAB 'type' function shows '�' letter incorrectly as 'A�' in xml file, 
% but opening the file in editor shows that it is correct.
fprintf('Test xml file:\n');
type('test_file.xml')
%%
% Read only the Root Element (default) 
[tree GlobalTextNodes] = xml_read('test_file.xml');
fprintf('Global Data (Root name, Global Processing Instructions and Global Comments):\n');
disp(GlobalTextNodes')
fprintf('\nStructure read from the file (uncludes COMMENT and CDATA sections):\n');
gen_object_display(tree);
%%
% Read the whole tree including global Comments and Processing Instructions
Pref=[]; Pref.RootOnly = false;
[tree GlobalTextNodes] = xml_read('test_file.xml', Pref);
fprintf('Global Data (Root name, Global Processing Instructions and Global Comments):\n');
disp(GlobalTextNodes')
fprintf('\nStructure read from the file (uncludes COMMENT and CDATA sections):\n');
gen_object_display(tree);

%% "Pref.ReadAttr" flag in "xml_read"
% Those option allow exclusion of attributes 
Pref=[]; Pref.ReadAttr = false; % do not read attributes
tree = xml_read('test_file.xml', Pref);
gen_object_display(tree);

%% Using "Pref.ReadSpec" flag in "xml_read"
% Those option allow exclusion of special nodes, like
% comments, processing instructions, CData sections, etc.
Pref=[]; Pref.ReadSpec = false; % do not read special node types
tree = xml_read('test_file.xml', Pref);
gen_object_display(tree);

%% "Pref.RootOnly" flag in "xml_read"
% As it was shown in previous examples RootOnly parameter can be used to
% capture global (top level) special nodes (like COMMENTs and
% PROCESSING_INSTRUCTIONs) which are ignored by default
Pref=[]; Pref.RootOnly = false; % do not read special node types
tree = xml_read('test_file.xml', Pref);
gen_object_display(tree);

%% "Pref.RootOnly" flag in "xml_write"
% Writing previously read tree with default "Pref.RootOnly = true" gives
% wrong output file
Pref=[]; Pref.RootOnly = true; % do not read special node types
xml_write('test.xml', tree, [], Pref);
fprintf('Test xml file:\n');
type('test.xml')
%%
% Writing the same tree with "Pref.RootOnly = false" gives correct output
Pref=[]; Pref.RootOnly = false; % do not read special node types
xml_write('test.xml', tree, [], Pref);
fprintf('Test xml file:\n');
type('test.xml')

%% "Pref.NumLevels" flag in "xml_read"
% This parameter allows user to skip parts of the tree in order to save
% time and memory. Usefull only in a rare case when a small portion of
% large XML file is needed.
%
% Create test tile
MyTree = [];
MyTree.Level1 = 1;
MyTree.Level1_.Level2 = 2;
MyTree.Level1_.Level2_.Level3 = 3;
MyTree.Level1_.Level2_.Level3_.Level4 = 4;
xml_write('test.xml', MyTree);
fprintf('Test xml file:\n');
type('test.xml')
%%
% *Use Default ("Pref.NumLevels = infinity") setting*
tree = xml_read('test.xml');
gen_object_display(tree);
%%
% *Limit the read to only 2 levels*
Pref=[]; Pref.NumLevels = 2; 
tree = xml_read('test.xml', Pref);
gen_object_display(tree);




%% Create DOM object based on a Struct using "xml_write"
% *Create Struct tree*
MyTree=[];
MyTree.MyNumber = 13;
MyTree.MyString = 'Hello World';
%%
% *Convert Struct to DOM object using xml_write*
DOM = xml_write([], MyTree); 
xmlwrite('test.xml', DOM);   % Save DOM object using MATLAB function 
type('test.xml')

%% Convert DOM object to Struct using "xml_read"
DOM = xmlread('test.xml');       % Read DOM object using MATLAB function
[tree treeName] = xml_read(DOM); % Convert DOM object to Struct
disp([treeName ' ='])
gen_object_display(tree)

%% Write XML file based on a DOM using "xml_write_xerces"
xmlwrite_xerces('test.xml', DOM); % Save DOM object using Xerces library 
type('test.xml')
