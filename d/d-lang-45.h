/* GDC -- D front-end for GCC
   Copyright (C) 2010 Iain Buclaw

   This program is free software; you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation; either version 2 of the License, or
   (at your option) any later version.
 
   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.
 
   You should have received a copy of the GNU General Public License
   along with this program; if not, write to the Free Software
   Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
*/

/* Same as d-lang.h, but updated to support GCC-4.5's new GTY(()) convention */

#ifndef GCC_DCMPLR_DC_LANG_H
#define GCC_DCMPLR_DC_LANG_H

/* Nothing is added to tree_identifier; */
struct GTY(()) lang_identifier
{
    struct tree_identifier ignore;
};

/* This is required to be defined, but we do not use it. */
struct GTY(()) language_function
{
    int unused;
};

/* The DMD front end types have not been integrated into the GCC garbage
   collection system.  Handle this by using the "skip" attribute. */
struct Declaration;
typedef struct Declaration *DeclarationGTYP;
struct GTY(()) lang_decl
{
    DeclarationGTYP GTY ((skip(""))) d_decl;
};

/* The lang_type field is not set for every GCC type. */
struct Type;
typedef struct Type *TypeGTYP;
struct GTY(()) lang_type
{
    TypeGTYP GTY((skip(""))) d_type;
};

/* Another required, but unused declaration.  This could be simplified, since
   there is no special lang_identifier */
union GTY((desc ("TREE_CODE (&%h.generic) == IDENTIFIER_NODE"),
           chain_next ("(union lang_tree_node *)TREE_CHAIN (&%h.generic)")))
lang_tree_node 
{
    union tree_node GTY ((tag ("0"), 
                          desc ("tree_node_structure (&%h)"))) 
      generic;
    struct lang_identifier GTY ((tag ("1"))) identifier;
};

extern GTY(()) tree d_eh_personality_decl;

/* True if the Tdelegate typed expression is not really a variable,
   but a literal function / method reference */
#define D_IS_METHOD_CALL_EXPR(NODE) (TREE_LANG_FLAG_0(NODE))

/* True if the symbol should be made "link one only".  This is used to
   defer calling make_decl_one_only() before the decl has been prepared. */
#define D_DECL_ONE_ONLY(NODE) (DECL_LANG_FLAG_0(NODE))

/* True if the symbol is a template member.  Need to distinguish
   between templates and other shared static data so that the latter
   is not affected by -femit-templates. */
#define D_DECL_IS_TEMPLATE(NODE) (DECL_LANG_FLAG_1(NODE))

/* True if the function has been marked "naked". */
#define D_DECL_NO_FRAME_POINTER(NODE) (DECL_LANG_FLAG_2(NODE))

/* True if the label has been computed, or used by the frontend. */
#define D_LABEL_IS_USED(NODE) (DECL_LANG_FLAG_3(NODE))

/* The D front-end does not use the 'binding level' system for a symbol table,
   It is only needed to get debugging information for local variables and
   otherwise support the backend. */
struct GTY(()) binding_level
{
    /* A chain of declarations. These are in the reverse of the order supplied. */
    tree names;

    /* A pointer to the end of the names chain. Only needed to facilitate
       a quick test if a decl is in the list by checking if its TREE_CHAIN
       is not NULL or it is names_end (in pushdecl_nocheck()). */
    tree names_end;

    /* For each level (except the global one), a chain of BLOCK nodes for
       all the levels that were entered and exited one level down. */
    tree blocks;

    /* The BLOCK node for this level, if one has been preallocated.
       If NULL_TREE, the BLOCK is allocated (if needed) when the level is popped. */
    tree this_block;

    /* The binding level this one is contained in. */
    struct binding_level *level_chain;
};

extern GTY(()) struct binding_level * current_binding_level;
extern GTY(()) struct binding_level * global_binding_level;

extern GTY(()) tree intmax_type_node;
extern GTY(()) tree uintmax_type_node;
extern GTY(()) tree signed_size_type_node;
extern GTY(()) tree string_type_node;
extern GTY(()) tree const_string_type_node;

extern GTY(()) tree d_null_pointer;
extern GTY(()) tree d_void_zero_node;
extern GTY(()) tree d_vtbl_ptr_type_node;

extern GTY(()) tree d_char_type_node;
extern GTY(()) tree d_wchar_type_node;
extern GTY(()) tree d_dchar_type_node;
extern GTY(()) tree d_ifloat_type_node;
extern GTY(()) tree d_idouble_type_node;
extern GTY(()) tree d_ireal_type_node;

extern GTY(()) tree null_node;

#ifdef __cplusplus
/* In d-lang.cc.  These are called through function pointers
   and do not need to be "extern C". */
extern bool d_mark_addressable PARAMS ((tree));
extern tree d_truthvalue_conversion PARAMS ((tree));
extern tree d_convert_basic PARAMS ((tree, tree));
extern void d_init_exceptions PARAMS ((void));

extern void init_global_binding_level(void);
extern void set_decl_binding_chain(tree decl_chain);

extern void d_add_global_function PARAMS(( tree ));

extern tree d_type_promotes_to(tree);

extern void gcc_d_backend_init();
extern void gcc_d_backend_term();

struct Module;
extern Module * d_gcc_get_output_module();

extern struct lang_type * build_d_type_lang_specific(Type * t);

/* In asmstmt.cc */
struct IRState;
extern bool d_have_inline_asm();
extern void d_expand_priv_asm_label(IRState * irs, unsigned n);
extern tree d_build_asm_stmt(tree t1, tree t2, tree t3, tree t4);

#endif

#ifdef __cplusplus
extern "C" {
#endif
/* In d-lang.cc */
tree pushdecl PARAMS ((tree));
void pushlevel PARAMS ((int));
tree poplevel PARAMS ((int, int, int));
tree d_unsigned_type(tree);
tree d_signed_type(tree);
tree d_type_for_size(unsigned bits, int unsignedp);
tree d_type_for_mode(enum machine_mode mode, int unsignedp);
tree d_build_decl_loc(location_t loc, enum tree_code code, tree name, tree type);
tree d_build_decl(enum tree_code code, tree name, tree type);
void dkeep(tree t);
    
/* In d-builtins.c */
extern void d_init_builtins PARAMS ((void));
extern const struct attribute_spec d_common_attribute_table[];
extern const struct attribute_spec d_common_format_attribute_table[];
extern tree d_builtin_function PARAMS ((const char *, tree, int, enum built_in_class, const char *, tree));
extern tree d_builtin_function43 PARAMS ((tree));

/* In d-misc.c */
extern int d_using_sjlj_exceptions PARAMS ((void));
extern char * d_asm_format_private_name PARAMS ((const char *,int));

/* In d-builtins2.cc */
extern void d_bi_init(int nt, int nb);
extern void d_bi_builtin_func(tree decl);

#ifdef __cplusplus
}
#endif

/* protect from garbage collection */
extern GTY(()) tree d_keep_list;

#include "d-dmd-gcc.h"

typedef HOST_WIDE_INT hwint;
typedef unsigned HOST_WIDE_INT uhwint;

#define d_warning(option, ...) warning(option, __VA_ARGS__)

#endif