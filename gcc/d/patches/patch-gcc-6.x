This implements D language support in the GCC back end, and adds
relevant documentation about the GDC front end.
---

--- gcc/config/darwin.h
+++ gcc/config/darwin.h
@@ -49,6 +49,10 @@ see the files COPYING3 and COPYING.RUNTIME respectively.  If not, see
 /* Suppress g++ attempt to link in the math library automatically. */
 #define MATH_LIBRARY ""
 
+/* Suppress gdc attempt to link in the thread and time library automatically. */
+#define THREAD_LIBRARY ""
+#define TIME_LIBRARY ""
+
 /* We have atexit.  */
 
 #define HAVE_ATEXIT
--- gcc/config/i386/cygming.h
+++ gcc/config/i386/cygming.h
@@ -170,6 +170,10 @@ along with GCC; see the file COPYING3.  If not see
 
 #undef MATH_LIBRARY
 #define MATH_LIBRARY ""
+#undef THREAD_LIBRARY
+#define THREAD_LIBRARY ""
+#undef TIME_LIBRARY
+#define TIME_LIBRARY ""
 
 #undef TARGET_LIBC_HAS_FUNCTION
 #define TARGET_LIBC_HAS_FUNCTION no_c99_libc_has_function
--- gcc/config/linux-android.h
+++ gcc/config/linux-android.h
@@ -57,3 +57,9 @@
 
 #define ANDROID_ENDFILE_SPEC \
   "%{shared: crtend_so%O%s;: crtend_android%O%s}"
+
+/* Suppress gdc attempt to link in the thread and time library automatically. */
+#if ANDROID_DEFAULT
+# define THREAD_LIBRARY ""
+# define TIME_LIBRARY ""
+#endif
--- gcc/config/rs6000/rs6000.c
+++ gcc/config/rs6000/rs6000.c
@@ -25783,7 +25783,8 @@ rs6000_output_function_epilogue (FILE *file,
       if (lang_GNU_C ()
 	  || ! strcmp (language_string, "GNU GIMPLE")
 	  || ! strcmp (language_string, "GNU Go")
-	  || ! strcmp (language_string, "libgccjit"))
+	  || ! strcmp (language_string, "libgccjit")
+	  || ! strcmp (language_string, "GNU D"))
 	i = 0;
       else if (! strcmp (language_string, "GNU F77")
 	       || lang_GNU_Fortran ())
--- gcc/doc/frontends.texi
+++ gcc/doc/frontends.texi
@@ -9,6 +9,7 @@
 @cindex GNU Compiler Collection
 @cindex GNU C Compiler
 @cindex Ada
+@cindex D
 @cindex Fortran
 @cindex Go
 @cindex Java
@@ -17,7 +18,7 @@
 GCC stands for ``GNU Compiler Collection''.  GCC is an integrated
 distribution of compilers for several major programming languages.  These
 languages currently include C, C++, Objective-C, Objective-C++, Java,
-Fortran, Ada, and Go.
+Fortran, Ada, D and Go.
 
 The abbreviation @dfn{GCC} has multiple meanings in common use.  The
 current official meaning is ``GNU Compiler Collection'', which refers
--- gcc/doc/install.texi
+++ gcc/doc/install.texi
@@ -1547,12 +1547,12 @@ their runtime libraries should be built.  For a list of valid values for
 grep ^language= */config-lang.in
 @end smallexample
 Currently, you can use any of the following:
-@code{all}, @code{ada}, @code{c}, @code{c++}, @code{fortran},
+@code{all}, @code{ada}, @code{c}, @code{c++}, @code{d}, @code{fortran},
 @code{go}, @code{java}, @code{jit}, @code{lto}, @code{objc}, @code{obj-c++}.
 Building the Ada compiler has special requirements, see below.
 If you do not pass this flag, or specify the option @code{all}, then all
 default languages available in the @file{gcc} sub-tree will be configured.
-Ada, Go, Jit, and Objective-C++ are not default languages.  LTO is not a
+Ada, D, Go, Jit, and Objective-C++ are not default languages.  LTO is not a
 default language, but is built by default because @option{--enable-lto} is
 enabled by default.  The other languages are default languages.
 
--- gcc/doc/invoke.texi
+++ gcc/doc/invoke.texi
@@ -1269,6 +1269,15 @@ called @dfn{specs}.
 Ada source code file containing a library unit body (a subprogram or
 package body).  Such files are also called @dfn{bodies}.
 
+@item @var{file}.d
+D source code file.
+
+@item @var{file}.di
+D interface code file.
+
+@item @var{file}.dd
+D documentation code file.
+
 @c GCC also knows about some suffixes for languages not yet included:
 @c Pascal:
 @c @var{file}.p
@@ -1304,6 +1313,7 @@ objective-c  objective-c-header  objective-c-cpp-output
 objective-c++ objective-c++-header objective-c++-cpp-output
 assembler  assembler-with-cpp
 ada
+d
 f77  f77-cpp-input f95  f95-cpp-input
 go
 java
--- gcc/doc/sourcebuild.texi
+++ gcc/doc/sourcebuild.texi
@@ -109,6 +109,9 @@ The Objective-C and Objective-C++ runtime library.
 @item libquadmath
 The runtime support library for quad-precision math operations.
 
+@item libphobos
+The D standard runtime library.
+
 @item libssp
 The Stack protector runtime library.
 
--- gcc/doc/standards.texi
+++ gcc/doc/standards.texi
@@ -280,6 +280,16 @@ available online, see @uref{http://gcc.gnu.org/readings.html}
 As of the GCC 4.7.1 release, GCC supports the Go 1 language standard,
 described at @uref{http://golang.org/doc/go1.html}.
 
+@section D language
+
+The D language is under development as of this writing; see the
+@uref{http://dlang.org/@/language-reference.html, current language
+reference}.  At present the current major version of D is 2.0, and
+there is no way to describe the language supported by GCC in terms of
+a specific minor version.  In general GCC follows the D frontend
+releases closely, and any given GCC release will support the current
+language as of the date that the release was frozen.
+
 @section References for Other Languages
 
 @xref{Top, GNAT Reference Manual, About This Guide, gnat_rm,
--- gcc/dwarf2out.c
+++ gcc/dwarf2out.c
@@ -4735,6 +4735,16 @@ is_ada (void)
   return lang == DW_LANG_Ada95 || lang == DW_LANG_Ada83;
 }
 
+/* Return TRUE if the language is D.  */
+
+static inline bool
+is_dlang (void)
+{
+  unsigned int lang = get_AT_unsigned (comp_unit_die (), DW_AT_language);
+
+  return lang == DW_LANG_D;
+}
+
 /* Remove the specified attribute if present.  Return TRUE if removal
    was successful.  */
 
@@ -20244,6 +20254,8 @@ gen_compile_unit_die (const char *filename)
 	language = DW_LANG_ObjC;
       else if (strcmp (language_string, "GNU Objective-C++") == 0)
 	language = DW_LANG_ObjC_plus_plus;
+      else if (strcmp (language_string, "GNU D") == 0)
+	language = DW_LANG_D;
       else if (dwarf_version >= 5 || !dwarf_strict)
 	{
 	  if (strcmp (language_string, "GNU Go") == 0)
@@ -21269,7 +21281,7 @@ declare_in_namespace (tree thing, dw_die_ref context_die)
 
   if (ns_context != context_die)
     {
-      if (is_fortran ())
+      if (is_fortran () || is_dlang ())
 	return ns_context;
       if (DECL_P (thing))
 	gen_decl_die (thing, NULL, ns_context);
@@ -21292,7 +21304,7 @@ gen_namespace_die (tree decl, dw_die_ref context_die)
     {
       /* Output a real namespace or module.  */
       context_die = setup_namespace_context (decl, comp_unit_die ());
-      namespace_die = new_die (is_fortran ()
+      namespace_die = new_die (is_fortran () || is_dlang ()
 			       ? DW_TAG_module : DW_TAG_namespace,
 			       context_die, decl);
       /* For Fortran modules defined in different CU don't add src coords.  */
@@ -21355,7 +21367,7 @@ gen_decl_die (tree decl, tree origin, dw_die_ref context_die)
       break;
 
     case CONST_DECL:
-      if (!is_fortran () && !is_ada ())
+      if (!is_fortran () && !is_ada () && !is_dlang ())
 	{
 	  /* The individual enumerators of an enum type get output when we output
 	     the Dwarf representation of the relevant enum type itself.  */
@@ -21866,7 +21878,7 @@ dwarf2out_decl (tree decl)
     case CONST_DECL:
       if (debug_info_level <= DINFO_LEVEL_TERSE)
 	return;
-      if (!is_fortran () && !is_ada ())
+      if (!is_fortran () && !is_ada () && !is_dlang ())
 	return;
       if (TREE_STATIC (decl) && decl_function_context (decl))
 	context_die = lookup_decl_die (DECL_CONTEXT (decl));
--- gcc/gcc.c
+++ gcc/gcc.c
@@ -1149,6 +1149,7 @@ static const struct compiler default_compilers[] =
   {".java", "#Java", 0, 0, 0}, {".class", "#Java", 0, 0, 0},
   {".zip", "#Java", 0, 0, 0}, {".jar", "#Java", 0, 0, 0},
   {".go", "#Go", 0, 1, 0},
+  {".d", "#D", 0, 1, 0}, {".dd", "#D", 0, 1, 0}, {".di", "#D", 0, 1, 0},
   /* Next come the entries for C.  */
   {".c", "@c", 0, 0, 1},
   {"@c",
