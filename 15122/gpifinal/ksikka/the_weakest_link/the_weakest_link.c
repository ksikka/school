#include <assert.h>
#include <stdlib.h>
#include <stdio.h>

/*
 * A linked-list node (or, if you prefer, a "cons cell"). Contains a value and
 * a link (pointer) to the next node in the list.
 */
typedef struct node {
	int value;
	struct node *next;
} node_t;

/**
 * Inserts an element at the head of a list
 * 
 * @arg list The list to add to; NULL represents an empty list
 * @arg value The value to add to the list
 * @return A pointer to the new head of the list
 */
node_t *list_add_head(node_t *list, int value)
{
	node_t *new_node = malloc(sizeof(node_t));
	assert(new_node != NULL);

	new_node->value = value;
	new_node->next = list;

	return new_node;
}

/* Inserts an element at the tail of a list  */
node_t *list_add_tail(node_t *list, int value)
{
	node_t *new_node = malloc(sizeof(node_t));
	assert(new_node != NULL);
	node_t *temp = list;

	new_node->value = value;
	new_node->next = NULL;

  if(temp == NULL) return new_node;


	while (temp->next != NULL) {
		temp = temp->next;
	}

	temp->next = new_node;

	return list;
}

/**
 * Finds a node with the given value in a list
 */
node_t *list_find(node_t *list, int value)
{
	while (list != NULL) {
		if (list->value == value) {
			return list;
		}
		list = list->next;
	}

	return NULL;
}

/**
 * Deletes a node from a list
 *
 * @arg list The list to search
 * @arg kill The node to find and remove (gets freed)
 * @return The new list
 */
node_t *list_delete(node_t *list, node_t *kill)
{
	node_t *temp = list;
  
  if(list == NULL) return NULL;
  if(kill == NULL) return list;
  
  
  // case where kill is the first node
  if(temp == kill)
  {
    temp = temp->next;
    free(kill);
    return temp;
  }
  // kill is not first. iterate until next = kill
	while (temp != NULL && temp->next != kill) {
		temp = temp->next;
	}
  // we reached null without finding kill. kill not found
	if (temp == NULL) {
		return list;
	}
  // by this point, kill is temp->next
  assert(kill == temp->next);
 
  temp->next = kill->next;
	free(kill);

	return list;
}

/**
 * Print out all the values in a list
 */
void list_dump(node_t *list)
{
    
  if(list == NULL)return;
  node_t *temp = list;
		while(temp != NULL)
    {
      printf("%d", temp->value);
      temp = temp->next;
      
      if(temp != NULL) printf(", ");
    }

	printf("\n");
}

/**
 * Delete a list
 */
void list_destroy(node_t *list)
{
	node_t *temp;
  if(list == NULL) return;

	while (list->next != NULL) {
		temp = list->next;
		free(list);
		list = temp;
	}
  free(list);
}

int main(int argc, char *argv[])
{
	int i;
	node_t *list1 = NULL;
	node_t *list2 = NULL;

	/* 
	 * This takes the arguments which were passed on the command line
	 * and puts them in the lists.
	 *
	 * argv[0] is the name of the program. argv[1] ... argv[argc-1] are
	 * the arguments which were passed on the command line.
	 *
	 * atoi() is a function which takes a string and returns an int--
	 * so atoi("54") is 54. See `man atoi` for more.
	 */
	for (i = 1; i < argc; i++) {
		int val = atoi(argv[i]);
		list1 = list_add_head(list1, val);
		list2 = list_add_tail(list2, val);
	}
	list_dump(list1);
	list_dump(list2);

	if (argc > 1) {
    list1 = list_delete(list1, list_find(list1, atoi(argv[1])));
		list2 = list_delete(list2, list_find(list2, atoi(argv[1])));
	}

	list_dump(list1);
	list_dump(list2);

	list_destroy(list1);
	list_destroy(list2);

	return 0;
}
