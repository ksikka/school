#include <assert.h>
#include <limits.h>
#include <stdlib.h>
#include <signal.h>

#include "xalloc.h"
#include "contracts.h"
#include "stacks.h"

#include "bare.h"
#include "c0vm.h"
#include "c0vm_c0ffi.h"


/* call stack frames */
typedef struct frame * frame;
struct frame {
    c0_value *V; /* local variables */
    stack S;     /* operand stack */
    ubyte *P;    /* function body */
    int pc;      /* return address */
};


/* functions for handling errors */
void c0_memory_error(char *err) {
    fprintf(stderr, "Memory error: %s\n", err);
    raise(SIGUSR1);
}

void c0_division_error(char *err) {
    fprintf(stderr, "Division error: %s\n", err);
    raise(SIGUSR2);
}


/* TODO: implement execute function */
int execute(struct bc0_file *bc0) {
    REQUIRES( bc0 != NULL );
    /* Variables used for bytecode interpreter. You will need to initialize
       these appropriately. */

    /* callStack to hold frames when functions are called */
    stack callStack;
    /* initial program is the "main" function, function 0 (which must exist) */
    struct function_info *main_fn;
    /* array to hold local variables for function */
    c0_value *V;
    /* stack for operands for computations */
    stack S;
    /* array of (unsigned) bytes that make up the program */
    ubyte *P;
    /* program counter that holds "address" of next bytecode to interpret from
       program P */
    int pc;
    //Task 1: initializing the variables
    callStack = stack_new();
    main_fn = bc0->function_pool;
    V = xmalloc( main_fn->num_vars * sizeof(c0_value) );
    S = stack_new();
    P = main_fn->code;
    pc = 0; //beginning of code
    while (true) {

    #ifdef DEBUG
      printf("Executing opcode %x  --- Operand stack size: %d\n",
             P[pc], stack_size(S));
    #endif

        switch (P[pc])
        {
                /* Additional stack operation: */
      	    case POP:
            {
                pop(S);
                pc++;
                break;
            }
            case DUP: {
                c0_value v = pop(S);
                push(S, v);
                push(S, v);
                pc++;
                break;
            }
            case SWAP: {
                c0_value v1 = pop(S);
                c0_value v2 = pop(S);
                push(S, v2);
                push(S, v1);
                pc++;
                break;
            }
            /* Arithmetic and Logical operations */
            case IADD:
            {
                unsigned int a = INT(pop(S));
                unsigned int b = INT(pop(S));
                unsigned int c = a+b; //unsigned computes modularly
                push(S, VAL(c));
                pc++;
                break;
            }
            case ISUB: {
                unsigned int a = INT(pop(S));
                unsigned int b = INT(pop(S));
                unsigned int c = b-a;
                push(S, VAL(c));
                pc++;
                break;
            }
            case IMUL: {
                unsigned int a = INT(pop(S));
                unsigned int b = INT(pop(S));
                unsigned int c = a*b;
                push(S, VAL(c));
                pc++;
                break;
            }
            case IDIV: {
                unsigned int a = INT(pop(S));
                unsigned int b = INT(pop(S));
                if(a == 0) c0_division_error("Div by zero");
                unsigned int c = b/a;
                push(S, VAL(c));
                pc++;
                break;
            }
            case IREM: {
                unsigned int a = INT(pop(S));
                unsigned int b = INT(pop(S));
                if(a == 0) c0_division_error("Mod by zero");
                unsigned int c = b%a;
                push(S, VAL(c));
                pc++;
                break;
            }
            case IAND: {
                unsigned int a = INT(pop(S));
                unsigned int b = INT(pop(S));
                unsigned int c = a&b;
                push(S, VAL(c));
                pc++;
                break;
            }
            case IOR: {
                unsigned int a = INT(pop(S));
                unsigned int b = INT(pop(S));
                unsigned int c = a|b;
                push(S, VAL(c));
                pc++;
                break;
            }
            case IXOR: {
                unsigned int a = INT(pop(S));
                unsigned int b = INT(pop(S));
                unsigned int c = a^b;
                push(S, VAL(c));
                pc++;
                break;
            }
            case ISHL: {
                unsigned int a = INT(pop(S));
                unsigned int b = INT(pop(S));
                unsigned int c = b<<a;
                push(S, VAL(c));
                pc++;
                break;
            }
            case ISHR: {
                unsigned int a = INT(pop(S));
                unsigned int b = INT(pop(S));
                unsigned int c = b>>a;
                push(S, VAL(c));
                pc++;
                break;
            }
            /* Pushing small constants */
            case BIPUSH: {
                byte c = P[pc +1];
                push(S,VAL(c));
                pc = pc + 2;
                break;
            }
            case RETURN: {
                c0_value ret = pop(S); //value to be returned
                free(V);
                stack_free(S, free); 
                if(stack_empty(callStack)) //this is a return from main
                {
                  stack_free(callStack, free);
                  return INT(ret);
                }
                else //this is a return from a user-defined function
                {
                  frame fr = pop(callStack); //store the previous function
                  pc = fr->pc;
                  V = fr->V;
                  S = fr->S;
                  P = fr->P;
                  free(fr); //this was malloc'd by invokestatic 
                  push(S, ret);
                  break;
                }
            }
            /* Operations on local variables */
            case VLOAD: {
                ubyte c = P[pc + 1];
                push(S, V[c]);
                pc = pc + 2;
                break;
            }
            case VSTORE: {
                ubyte c = P[pc + 1];
                V[c] = pop(S);
                pc = pc + 2;
                break;
            }              
            case ACONST_NULL:
            {
                push(S,NULL);
                pc++;
                break;
            }
            case ILDC: {
                int c1 = P[pc + 1] << 8 ;
                int c2 = P[pc + 2];
                int x = bc0->int_pool[c1|c2];
                push(S, VAL(x));
                pc = pc + 3;
                break;
            }
            case ALDC: {
                unsigned int c1 = P[pc + 1] << 8 ;
                ubyte c2 = P[pc + 2];
                char* a = &(bc0->string_pool[c1|c2]);
                push(S, VAL(a));
                pc = pc + 3;
                break;
            }
            /* Control flow operations */
            case NOP:
            {
              pc++;
              break;
            }
            case IF_CMPEQ:
            {
              int v1 = INT(pop(S));
              int v2 = INT(pop(S));
              int o1 = INT(P[pc + 1]);
              int o2 = INT(P[pc + 2]);
              if(v1 == v2)             
                pc = pc + ((o1<<8)|o2);
              else pc = pc + 3;
              break;
            }
            case IF_CMPNE:
            {
              int v1 = INT(pop(S));
              int v2 = INT(pop(S));
              int o1 = INT(P[pc + 1]);
              int o2 = INT(P[pc + 2]);
              if(v1 != v2)             
                pc = pc + ((o1<<8)|o2);
              else pc = pc + 3;
              break;
            }
            case IF_ICMPLT:
            {
              int v2 = INT(pop(S));
              int v1 = INT(pop(S));
              int o1 = INT(P[pc + 1]);
              int o2 = INT(P[pc + 2]);
              if(v1 < v2)             
                pc = pc + ((o1<<8)|o2);
              else pc = pc + 3;
              break;
            }
            case IF_ICMPGE:
            {
              int v2 = INT(pop(S));
              int v1 = INT(pop(S));
              int o1 = INT(P[pc + 1]);
              int o2 = INT(P[pc + 2]);
              if(v1 >= v2)             
                pc = pc + ((o1<<8)|o2);
              else pc = pc + 3;
              break;
            }
            case IF_ICMPGT:
            {
              int v2 = INT(pop(S));
              int v1 = INT(pop(S));
              int o1 = INT(P[pc + 1]);
              int o2 = INT(P[pc + 2]);
              if(v1 > v2)             
                pc = pc + ((o1<<8)|o2);
              else pc = pc + 3;
              break;
            }
            case IF_ICMPLE:
            {
              int v2 = INT(pop(S));
              int v1 = INT(pop(S));
              int o1 = INT(P[pc + 1]);
              int o2 = INT(P[pc + 2]);
              if(v1 <= v2)             
                pc = pc + ((o1<<8)|o2);
              else pc = pc + 3;
              break;
            }
            case GOTO:
            {
              ubyte o1 = INT(P[pc + 1]);
              ubyte o2 = INT(P[pc + 2]);
              pc = pc + (short int)((o1 << 8)|o2);
              break;
            }
            /* Function call operations: */
            case INVOKESTATIC:
            {
              int c1 = INT(P[pc+1]);
              int c2 = INT(P[pc+2]);
              int a = (c1<<8)|c2;
              frame fr = xmalloc(sizeof(struct frame));
              int num_vars,num_args,i;
              fr->P = P;
              fr->S = S;
              fr->pc = pc + 3;
              fr->V = V;
              push(callStack, fr);
              num_vars = main_fn[a].num_vars;
              num_args = main_fn[a].num_args;
              V = xmalloc(sizeof(c0_value) * num_vars);
              for(i = 0;i < num_args; i++) 
              {
                V[num_args - i - 1] = pop(S);
              }
              S = stack_new();
              P = main_fn[1].code;
              pc = 0;
              break;
            }              

            case INVOKENATIVE:
            {
              int c1 = P[pc + 1] << 8; 
              int c2 = P[pc + 2];
              struct native_info fn_info = bc0->native_pool[c1|c2];
              int num_args = fn_info.num_args;
              int i;
              c0_value ret = NULL;
              c0_value (*g)(c0_value*); //function pointer
              c0_value* V2 = xmalloc(num_args * sizeof(c0_value));
              for(i = 0; i < num_args; i++) V2[num_args - i - 1] = pop(S);
              g = native_function_table[fn_info.function_table_index];
              ret = g(V2);
              push(S, ret);
              free(V2);
              pc = pc + 3;
              break;
            }
            /* Memory allocation operations: */
            case NEW:
            {
              ubyte size = P[pc + 1];
              c0_value * x = malloc(size);
              if(x == NULL){
                c0_memory_error("No memory left to allocate");
              }
              else { push(S,x); }
              pc = pc + 2;
              break;
            }
            case NEWARRAY:
            {
              int size = P[pc + 1];
              int n = INT(pop(S));
              int * array = xcalloc(1,2*sizeof(int) + n*size); //2 ints and n elements
              array[0] = n;
              array[1] = size;
              push(S, (c0_value)array);
              pc = pc + 2;
              break;
            }
            case ARRAYLENGTH:
            {
              int * array = (int*)pop(S); // for reading 1st 2 ints
              if(array == NULL) c0_memory_error("Can't find length of NULL");
              int length = array[0];
              push(S, VAL(length));
              pc++;
              break;
            }
            /* Memory access operations: */
            case AADDF:
            {
              ubyte field_offset = P[pc + 1];
              int * array = (int*)pop(S); //use int* to do address arithmetic
              byte * b_array = (byte*)(array+2);
              if((array == NULL) || (b_array == NULL))
                  c0_memory_error("Attempted NULL memory access");
              push(S, (void*)( array + field_offset));
              pc = pc + 2;
              break;
            }
            case AADDS:
            {
              int index = INT(pop(S));
              int * array = (int*)pop(S);
              byte * b_array = (byte*)(array + 2);
              if((array == NULL) || (b_array == NULL))
                  c0_memory_error("Attempted NULL memory access");
              int length = array[0]; //should get 1st 4 bytes
              if(!(0 <= index && index < length))
                  c0_memory_error("Index out of bounds");
              int elem_size = array[1]; //should get 2nd 4 bytes
              byte* elem_address = b_array + index*elem_size;
              push(S, (c0_value)elem_address);
              pc++;
              break;
            }
            case IMLOAD:
            {
              int * ptr = (int*)pop(S); //use int because it is 4 bytes
              if(ptr == NULL)
                  c0_memory_error("Attempted NULL memory access");
              int value = *ptr;
              push(S, VAL(value));
              pc++;
              break;
            }
            case IMSTORE:
            {
              int value = INT(pop(S));
              int * ptr = (int *) pop(S);
              if(ptr == NULL) c0_memory_error("Attempted NULL memory access");
              *ptr = value;
              pc++;
              break;
            }
            case AMLOAD:
            {
              void** a = (void**)pop(S);
              if(a == NULL) c0_memory_error("Attempted NULL memory access");
              if(*a == NULL) c0_memory_error("Attempted NULL memory access");
              void* b;
              b = *a;   
              push(S, b);
              pc++;
              break;
            }
            case AMSTORE:
            {
              void* b = pop(S);
              void** a = (void**)pop(S);
              if(a == NULL) c0_memory_error("Attempted NULL memory access");
              if(*a == NULL) c0_memory_error("Attempted NULL memory access");
              *a = b;
              pc++;
              break;
            }
            case CMLOAD:
            {
              char* ch = (char*)pop(S);
              int x = (int)(*ch);
              push(S, VAL(x));
              pc++;
              break;
            }
            case CMSTORE:
            {
              int x = INT(pop(S));
              x = x & 0x0000007F;
              char* ch = (char*)pop(S);
              *ch = x;
              pc++;
              break;
            }
                fprintf(stderr, "opcode not implemented: 0x%02x\n", P[pc]);
                abort();

            default:
                fprintf(stderr, "invalid opcode: 0x%02x\n", P[pc]);
                abort();
        }
    }

    /* cannot get here from infinite loop */
    assert(false);
}
