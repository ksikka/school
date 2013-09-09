/******************************************************************************
 *                    15-122 Principles of Imperative Computation, Fall 2011
 ******************************************************************************
 *   This implements the rope interface
 *
 * @author
 ******************************************************************************/
#include "ropes.h"
#include <stdlib.h>
#include <stdbool.h>
#include <string.h>

#include "contracts.h"
#include "xalloc.h"//.c"


/* Tests whether the rope satisfies the rope invariants. */
bool is_interior_rope(rope str);

/* Tests whether the rope satisfies the rope invariants. */
bool is_leaf_rope(rope str);

/* TODO: implement functions here (Tasks 1-8) */

bool is_rope(rope str) 
{
    return str != NULL &&
          ( is_leaf_rope(str) ||
             is_interior_rope(str) ) &&
              str->ref_count > 0;
}

bool is_interior_rope(rope str)
{
    return str != NULL &&
            str->data == NULL &&
             is_rope(str->left) &&
              is_rope(str->right) &&
               str->size == str->left->size + str->right->size &&
                str->position == str->left->size;
}

bool is_leaf_rope(rope str)
{
    return str != NULL &&
            str->data != NULL &&
             str->size == strlen(str->data) &&
              str->left == NULL &&
               str->right == NULL;
}

rope rope_new(char* str)
{
  REQUIRES(str != NULL);

  int length;
  char *data;
  rope R;
  
  //allocates memory for string, performs deep copy
  length = strlen(str);
  data = xmalloc((length+1) * sizeof(char));
  strcpy(data, str);
  
  //allocates memory for the rope, makes assignments
  R = xmalloc(sizeof(struct rope_node));
  R->left = NULL;
  R->right = NULL;
  R->size = length;
  R->position = 0;
  R->data = data;
  R->ref_count = 1;
  
  ENSURES(is_leaf_rope(R));
  return R;
}

rope rope_join(rope str1, rope str2)
{
    REQUIRES(is_rope(str1));
    REQUIRES(is_rope(str2));
    
    rope R;
    R = xmalloc(sizeof(struct rope_node));
    R->size = str1->size + str2->size;
    R->position = str1->size;
    R->left = str1;
    R->right = str2;
    R->left->ref_count++;
    R->right->ref_count++;
    R->ref_count = 1;
    R->data = NULL;
    
    ENSURES(is_rope(R));
    
    return R;
}

void rope_free(rope str)
{
  REQUIRES(is_rope(str));

  if(str->ref_count == 1)
  {
    if(is_interior_rope(str))
    {
      str->left->ref_count--; 
      str->right->ref_count--; 
      rope_free(str->left);
      rope_free(str->right);
    }
    else 
    {
      ASSERT(is_leaf_rope(str));
      free(str->data);
    }
    free(str);
    return;
  }
  else return;
}

char rope_charat(rope str, size_t idx)
{
  REQUIRES(is_rope(str));
  REQUIRES(idx < str->size);

  rope temp = str; //rope to point at current node while traversing
  while(!is_leaf_rope(temp))
  {
    if(idx < temp->position) temp = temp->left; //if lt, go left
    else
    {
      idx -= temp->position; //before going right, adjust index
      temp = temp->right;    //go right
    }
  }
  return temp->data[idx];
}

char* rope_to_chararray(rope str)
{
REQUIRES(is_rope(str));

char *arr;
int i;

arr = xmalloc((str->size+1) * sizeof(char));
for(i = 0; i < (int)str->size; i++)
{
 *(arr + i) = rope_charat(str, (size_t)i);
} *(arr + i) = '\0'; //strings terminate in null character

ENSURES(( arr == NULL && is_interior_rope(str)) || 
        ( arr != NULL && is_rope(str)) );

return arr;
}

int rope_compare(rope str1, rope str2)
{
  REQUIRES(is_rope(str1));
  REQUIRES(is_rope(str2));

  char *arr1 = rope_to_chararray(str1);
  char *arr2 = rope_to_chararray(str2);
  int size = strcmp(arr1, arr2);
  free(arr1); free(arr2);

  ENSURES(size == -1 || size == 0 || size == 1);

  return size;  
}

rope rope_sub(rope str, int i, int j)
{
  REQUIRES(0 <= i);
  REQUIRES(i < j);
 
  //since indeces are positive, we can make them unsigned for comparisons
  unsigned int ui = (unsigned int)i;
  unsigned int uj = (unsigned int)j;
  
  REQUIRES(is_rope(str));
  REQUIRES(uj <= str->size); 

  if(is_leaf_rope(str))
  { //if leaf, get the chars from the data field
    int length = uj - ui;
    char substr[length+1];
    int idx = 0;

    for(idx = 0; idx < length; idx++)
    {
      substr[idx] = rope_charat(str, ui + idx);
    } substr[length] = '\0';
    rope R = rope_new(substr);

    ENSURES(is_rope(R));
    return R;
  }
  else
  {
  ASSERT(is_interior_rope(str));
  if(uj < str->position) //left branch
    return rope_sub(str->left, ui, uj);
  else if(str->position <= ui)  //right branch
    return rope_sub(str->right, ui-str->position, uj-str->position);
  else if(ui < str->position && str->position <= uj) //both branches
    return rope_join( rope_sub(str->left, ui, str->position),
                      rope_sub(str->right, 0, uj-str->position) );
  }
  ASSERT(false); //as in, "the compiler should never get here..."
  return NULL; //to satisfy the compiler
}

/** MY TESTS. PLEASE IGNORE, GRADER. **/
/*
int main()
{
rope R = rope_new("te");
rope S = rope_new("st");
rope T = rope_new("ing");
rope c = rope_join(R,S);
rope P = rope_join(c,T);
char * john = rope_to_chararray(P);
int i;
for(i = 0; i < 7; i++)
{
 printf("%c\n",*(john+i));
}

rope a = rope_sub(P, 2, 5);
free(john);

john = rope_to_chararray(a);
printf("%s\n",john);
free(john);

rope_free(P);
rope_free(a);
return 0;
}
*/
