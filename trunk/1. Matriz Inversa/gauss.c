#include <stdio.h>
#define MAX_COLUMN 30
#define MAX_ROW 30

void menu();
int input_operation();
void evaluate(int operation, float matrix[][MAX_ROW]);
void addition(float matrix[][MAX_ROW]);
void scalar_multiplication(float matrix[][MAX_ROW]);
void matrix_multiplication(float matrix[][MAX_ROW]);
void transpose(float matrix[][MAX_ROW]);
void inverse(float matrix[][MAX_ROW]);
void invert(float matrix[][MAX_ROW], int n);
void echelon(float m[(2*MAX_COLUMN)][MAX_ROW], int n);
int find_max_row(float m[(2*MAX_COLUMN)][MAX_ROW], int cur_column, int start_row, int end);
void reduce_echelon(float m[(2*MAX_COLUMN)][MAX_ROW], int index, int n);
void reverse_echelon(float m[][MAX_ROW], int index, int n);
void canonical_form(float m[][MAX_ROW], int index, int n);
float get_product(float a[][MAX_ROW], float b[][MAX_ROW], int cur_col, int cur_row, int p);
int get_size();
float get_values();
int input_scalar();
void print_matrix(char msg[], float m[][MAX_ROW], int column, int row);

int main()
{
	
	int operation;
	float matrix[MAX_COLUMN][MAX_ROW];
	
	menu();
	operation = input_operation();
	evaluate(operation, matrix);
	
	
}

/*
 * This function prints the menu for the user to choose what matrix operation to be used.
 *
 */

void menu()
{
	printf("\n-------------MENU--------------\n");
	printf("Choose the number corresponding\nto the operation to be used:\n");
	printf("   [0]  Addition\n");
	printf("   [1]  Scalar Multiplication\n");
	printf("   [2]  Matrix Multiplication\n");
	printf("   [3]  Transpose\n");
	printf("   [4]  Inverse\n");
	printf("-------------------------------\n");
}

/*
 * This function obtains the input from the user.
 * Arguments:
 *		value: it is where the number input by the user will be stored
 * Returns a certain value.
 * 
 */

int input_operation()
{
	int value;
	
	printf("Operation: ");
	scanf("%d", &value);
	return value;
}

/*
 * This function evaluates the value input for the matrix operation to be used.
 * Arguments:
 *		operation: 	the value input by the user
 *		matrix: 		a 2-dimensional array where the values of the matrix are stored
 *
 */

void evaluate(int operation, float matrix[][MAX_ROW])
{
	if (operation == 0)
	{
		addition(matrix);
	}
	else if (operation == 1)
	{
		scalar_multiplication(matrix);
	}
	else if (operation == 2)
	{
		matrix_multiplication(matrix);
	}
	else if (operation == 3)
	{
		transpose(matrix);
	}
	else if (operation == 4)
	{
		inverse(matrix);
	}
	else
	{
		printf("\n				 INVALID!					\n");
		printf("Please enter correct value for the operation!\n");
		main();
	}
}

/*
 * This function is used to get the sum of 2 matrices of the same size. If this condition is not
 * met, it prints out an error message indicating that matrices cannot be added.
 * Arguments:
 *		matrix_a:	an array to store the values for matrix A
 * 	matrix_b:   an array to store the values of matrix B
 * 	sum:			an array to store the values obtained by summing the 2 matrices
 *		column_a, row_a,
 *		column_b, row_b: the size of the matrices
 *		size:			an array to store temporarily the sizes of the matrix
 *	  i, cur_column, cur_row: counter indices
 *
 */

void addition(float matrix[][MAX_ROW])
{
	float matrix_a[MAX_COLUMN][MAX_ROW];
	float matrix_b[MAX_COLUMN][MAX_ROW];
	float sum[MAX_COLUMN][MAX_ROW];
	int column_a;
	int row_a;
	int column_b;
	int row_b;
	int column;
	int row;
	const int SIZE = 2;
	int size[SIZE];
	int i;
	int cur_column;
	int cur_row;
	
	/*Obtains size and values for MATRIX A*/
	printf("\nMATRIX A:\n");
	printf("Size[# #]: ");
	for (i = 0; i < SIZE; i++)
	{
		size[i] = get_size();
	}
	
	column_a = size[0];
	row_a = size[1];
	
	for (cur_row = 0; cur_row < row_a; cur_row++)
	{
		for (cur_column = 0; cur_column < column_a; cur_column++)
		{
			matrix_a[cur_column][cur_row] = get_values();			
		}
	}
	
	/*Obtains size and values for MATRIX B*/
	printf("\nMATRIX B:\n");
	printf("Size[# #]: ");
	for (i = 0; i < SIZE; i++)
	{
		size[i] = get_size();
	}
	
	column_b = size[0];
	row_b = size[1];
	
	for (cur_row = 0; cur_row < row_b; cur_row++)
	{
		for (cur_column = 0; cur_column < column_b; cur_column++)
		{
			matrix_b[cur_column][cur_row] = get_values();			
		}
	}
	
	if ( (column_a == column_b) && (row_a == row_b))
	{
		column = column_a;
		row = row_a;
		for (cur_row = 0; cur_row < row; cur_row++)
		{
			for (cur_column = 0; cur_column < column; cur_column++)
			{
				sum[cur_column][cur_row] = matrix_a[cur_column][cur_row] + matrix_b[cur_column][cur_row];
			}
		}
		print_matrix("\n----- A + B -----\n", sum, column, row);		
	}
	else
	{
		printf("\nCANNOT PERFORM OPERATION!\nMatrices not of the same size.");
	}
}

/* 
 * This function is used to get the scalar product of a matrix and a constant.
 *	Arguments:
 *		matrix:  an array which the values of the matrix is stored
 *		scalar:  scalar constant
 *		column, row: the matrix size
 *		size:		an array where the matrix size is stored when scanned or obtained from the user
 *		i, cur_column, cur_row:	indices and counters
 *
 */

void scalar_multiplication(float matrix[][MAX_ROW])
{
	int scalar;
	float scalar_product[MAX_COLUMN][MAX_ROW];
	const int SIZE = 2;
	int size[SIZE];
	int cur_row;
	int cur_column;
	int i;
	int column;
	int row;
	
	scalar = input_scalar();
	
	printf("Size[# #]: ");
	for (i = 0; i < SIZE; i++)
	{
		size[i] = get_size();
	}
	
	column = size[0];
	row = size[1];
	
	for (cur_row = 0; cur_row < row; cur_row++)
	{
		for (cur_column = 0; cur_column < column; cur_column++)
		{
			matrix[cur_column][cur_row] = get_values();			
		}
	}
	
	for (cur_row = 0; cur_row < row; cur_row++)
	{
		for (cur_column = 0; cur_column < column; cur_column++)
		{
			scalar_product[cur_column][cur_row] = scalar * matrix[cur_column][cur_row];
		}
	}	
	print_matrix("\n------ k * A ------\n", scalar_product, column, row);
}

/*
 *	The function is used to get the product of 2 matrices A (mxp) and B (qxn) given that p = q.
 * The function prints an error message if this condition has not been met.
 * Arguments:
 *		product: an array where the values of the product of the matrices are stored
 *		matrix_a, matrix_b: arrays where the values of the matrices are stored
 *		column_a, row_a, column_b, row_b: the sizes of the matrices
 *		size: an array where the sizes of the matrices are temporarily stored
 *	i, cur_column, cur_row: indices and counters
 *
 */

void matrix_multiplication(float matrix[][MAX_ROW])
{
	float matrix_a[MAX_COLUMN][MAX_ROW];
	float matrix_b[MAX_COLUMN][MAX_ROW];
	float product[MAX_COLUMN][MAX_ROW];
	int column_a;
	int row_a;
	int column_b;
	int row_b;
	int column;
	int row;
	const int SIZE = 2;
	int size[SIZE];
	int i;
	int cur_column;
	int cur_row;
	
	/*Obtains size and values for MATRIX A*/
	printf("\nMATRIX A:\n");
	printf("Size[# #]: ");
	for (i = 0; i < SIZE; i++)
	{
		size[i] = get_size();
	}
	
	column_a = size[0];
	row_a = size[1];
	
	for (cur_row = 0; cur_row < row_a; cur_row++)
	{
		for (cur_column = 0; cur_column < column_a; cur_column++)
		{
			matrix_a[cur_column][cur_row] = get_values();			
		}
	}
	
	/*Obtains size and values for MATRIX B*/
	printf("\nMATRIX B:\n");
	printf("Size[# #]: ");
	for (i = 0; i < SIZE; i++)
	{
		size[i] = get_size();
	}
	
	column_b = size[0];
	row_b = size[1];
	
	for (cur_row = 0; cur_row < row_b; cur_row++)
	{
		for (cur_column = 0; cur_column < column_b; cur_column++)
		{
			matrix_b[cur_column][cur_row] = get_values();			
		}
	}
	
	if (row_a == column_b)
	{
		for (cur_row = 0; cur_row < row_b; cur_row++)
		{
			for (cur_column = 0; cur_column < column_a; cur_column++)
			{
				product[cur_column][cur_row] = get_product(matrix_a, matrix_b, cur_column, cur_row, row_a);
			}
		}
		print_matrix("\n----- A X B -----\n", product, column_a, row_b);
	}
	else
	{
		printf("\nNOT DEFINED!\n");
	}	
}

/*
 *	This function tranposes a matrix when called.
 * Arguments:
 *		trans_matrix:	an array where the values of the transposed matrix are stored
 *
 */

void transpose(float matrix[][MAX_ROW])
{
	float trans_matrix[MAX_COLUMN][MAX_ROW];
	const int SIZE = 2;
	int size[SIZE];
	int cur_row;
	int cur_column;
	int i;
	int column;
	int row;
	
	printf("Size[# #]: ");
	for (i = 0; i < SIZE; i++)
	{
		size[i] = get_size();
	}
	
	column = size[0];
	row = size[1];
	
	for (cur_row = 0; cur_row < row; cur_row++)
	{
		for (cur_column = 0; cur_column < column; cur_column++)
		{
			matrix[cur_column][cur_row] = get_values();			
		}
	}
	
	for (cur_row = 0; cur_row < column; cur_row++)
	{
		for (cur_column = 0; cur_column < row; cur_column++)
		{
			trans_matrix[cur_column][cur_row] = matrix[cur_row][cur_column];
		}
	}	
	print_matrix("\n------ TRANSPOSED MATRIX ------\n", trans_matrix, row, column);	
}

/*
 *	This function is used to obtain the inverse of a matrix nxn. If the matrix input is not a
 * square matrix, it prints out a message indicating that matrix is not invertible.
 *	Arguments:
 *		matrix:	an array where the values of the matrix are stored
 *		size: an array where the size of the matrix are temporarily stored when obtained from the user
 *	column, row: the size of the matrix
 *		i, cur_column, cur_row:	indices, counters
 *
 */

void inverse(float matrix[][MAX_ROW])
{
	const int SIZE = 2;
	int size[SIZE];
	int cur_row;
	int cur_column;
	int i;
	int column;
	int row;
	
	printf("Size[# #]: ");
	for (i = 0; i < SIZE; i++)
	{
		size[i] = get_size();
	}
	
	column = size[0];
	row = size[1];
	
	for (cur_row = 0; cur_row < row; cur_row++)
	{
		for (cur_column = 0; cur_column < column; cur_column++)
		{
			matrix[cur_column][cur_row] = get_values();			
		}
	}
	
	if (column == row)
	{
		invert(matrix, column);
	}
	else
	{
		printf("\nCANNOT PROCESS OPERATION!\nMatrix not invertible!\n\n");
	}	
}

/*
 *	This function is a subfunction of inverse. It creates an augmented matrix M[A|I] used to
 * work with Gaussian Elimination to get the inverse of a matrix where A is the matrix and 
 * I is the identity matrix.
 * Arguments:
 *		matrix: 	an array where the values of the matrix input are stored
 *		m:			an array where the values of the augmented matrix are stored
 *		i:			the identity matrix
 *
 */

void invert(float matrix[][MAX_ROW], int n)
{
	float m[(2*MAX_COLUMN)][MAX_ROW];		/*augmented matrix*/
	float i[MAX_COLUMN][MAX_ROW];				/*identity*/
	int cur_row;
	int cur_column;
	
	/*identity*/
	for (cur_row = 0; cur_row < n; cur_row++)
	{
		for (cur_column = 0; cur_column < n; cur_column++)
		{
			if (cur_row == cur_column)
			{
				i[cur_column][cur_row] = 1;
			}
			else
			{
				i[cur_column][cur_row] = 0;
			}
		}
	}
	
	/*augmented matrix, 1st half*/
	for (cur_row = 0; cur_row < n; cur_row++)
	{
		for (cur_column = 0; cur_column < n; cur_column++)
		{
			m[cur_column][cur_row] = matrix[cur_column][cur_row];
		}
	}
	/*augmented matrix, 2nd half*/
	for (cur_row = 0; cur_row < n; cur_row++)
	{
		for (cur_column = n; cur_column < (2 * n); cur_column++)
		{
			m[cur_column][cur_row] = i[(cur_column - n)][cur_row];
		}
	}
	
	echelon(m, n);
}

/*
 *	This is a subfunction of inverse where the augmented matrix is being reduced to echelon
 * form. If through the process of row operations a row zeros is obtained at the left side of
 * the augmented matrix or if any of the diagonal values is zero, it prints out an error 
 * message that the matrix has no inverse.
 *	Arguments:	
 *		m: the augmented matrix
 *		n: the size of the matrix being inverted
 *		inverse: an array to store the values of the inverted matrix
 *		temp: a temporary storage
 *
 */

void echelon(float m[(2*MAX_COLUMN)][MAX_ROW], int n)
{
	int i;										/*counter*/
	int cur_row;
	int cur_column;
	float inverse[MAX_COLUMN][MAX_ROW];
	float temp;  
	
	
	/*pivoting and swapping of rows*/
	for (i = 0; i < (n-1); i++)
	{
		for (cur_row = i; cur_row < n; cur_row++)
		{
			int row_index_max = find_max_row(m, i, cur_row, n);
			
			for (cur_column = 0; cur_column < (2*n); cur_column++)
			{
				temp = m[cur_column][cur_row];
				m[cur_column][cur_row] = m[cur_column][row_index_max];
				m[cur_column][row_index_max] = temp;
			}
			
		}
		reduce_echelon(m, i, n);
		
		if (m[i][i] == 0)
		{
			printf("\nMatrix has no inverse!\n\n");
		}
		
	}
	
	/*reverse row operations*/
	for (i = (n-1); i > 0;i--)
	{
		
		reverse_echelon(m, i, n);
		
	}
	
	/*reduces m to canonical form*/
	for (i = 0; i < n; i++)
	{
		canonical_form(m, i, n);
	}
	
	/*gets the inverse*/
	for (cur_row = 0; cur_row < n; cur_row++)
	{
		for (cur_column = 0; cur_column < n; cur_column++)
		{
			inverse[cur_column][cur_row] = m[(cur_column + n)][cur_row];
		}
	}
	print_matrix("\n----- INVERSE -----\n", inverse, n, n);
	
}

/*
 * This function is used to obtain the row which has the leading non-zero entry, an important
 * parameter in doing elementary row operations in obtaining the echelon form of an augmented
 * matrix.
 *	Arguments:
 * 	m: the augmented matrix
 *		cur_column, start_row, end: indices and counters
 * 	index_max_row: the index of the row which has the leading non-zero entry
 * Returns a value.
 *
 */

int find_max_row(float m[(2*MAX_COLUMN)][MAX_ROW], int cur_column, int start_row, int end)
{
	int index_max_row = start_row;
	int cur_row;
	
	for (cur_row = start_row; cur_row < end; cur_row++)
	{
		if (m[cur_column][cur_row] > m[cur_column][index_max_row])
		{
			index_max_row = cur_row;
		}
	}
	return index_max_row;
}

/*
 *	This function is used to get the echelon form of the augmented matrix.
 * Arguments:
 *		m: the augmented matrix
 *		index: the current index of the values of the augmented matrix being reduced to echelon
 *		n: the size of the matrix nxn being inverted
 *		temp: temporary storage
 *		factor: the factor used to reduce the values of the matrix into echelon
 *
 */

void reduce_echelon(float m[(2*MAX_COLUMN)][MAX_ROW], int index, int n)
{
	int cur_row;
	int cur_column;
	float temp;
	float factor;
	
	for (cur_row = index; cur_row < (n-1); cur_row++)
	{
		factor = m[index][(cur_row + 1)]/m[index][index];
		for (cur_column = index; cur_column < (n * 2); cur_column++)
		{
			temp = m[cur_column][(cur_row + 1)] - (factor * m[cur_column][index]);
			m[cur_column][(cur_row + 1)] = temp;
		}
	}
}

/*
 * This function is used for the reverse elementary row operations.
 *
 */

void reverse_echelon(float m[(2*MAX_COLUMN)][MAX_ROW], int index, int n)
{
	int cur_row;
	int cur_column;
	float temp;
	float factor;
	
	for (cur_row = index; cur_row > 0; cur_row--)
	{
		factor = m[index][(cur_row - 1)]/m[index][index];
		for (cur_column = index; cur_column < (2 * n); cur_column++)
		{
			temp = m[cur_column][(cur_row - 1)] - (factor * m[cur_column][index]);
			m[cur_column][(cur_row -1)] = temp;
		}
	}	
}

/*
 * This function is used to obtain the canonical form of the reduced echolon form of the 
 * augmented matrix.
 *
 */

void canonical_form(float m[(2*MAX_COLUMN)][MAX_ROW], int index, int n)
{
	int cur_column;
	float temp;
	float factor;
	
	factor = m[index][index];
	
	for (cur_column = index; cur_column < (n*2); cur_column++)
	{
		temp = m[cur_column][index]/factor; 
		m[cur_column][index] = temp;
	}
}

/*
 * This function is used to obtain the value of ijth entry of the product matrix.
 *	Arguments:
 *		a, b: arrays where the values of the matrices A and B are stored
 *		cur_col: the index of the current column value of the product
 *		p: equivalent to the row of A and column of B
 * 	sum: the value of the ijth entry of the product of matrices A and B
 *		product: temporary storage of the product of the ith row of A and jth column of B 
 * Returns a value.
 *
 */

float get_product(float a[][MAX_ROW], float b[][MAX_ROW], int cur_col, int cur_row, int p)
{
	float sum = 0;
	float product;
	int i;
	
	for (i = 0; i < p; i++)
	{
		product = a[cur_col][i] * b[i][cur_row];
		sum = sum + product;
	}
	return sum;
}

/*
 * This function is used to get the size of a matrix.
 * Arguments:
 * 	n:		a variable where to store the size input by the user
 * Returns a value.
 *
 */

int get_size()
{
	int n;
	
	scanf("%d", &n);
	return n;
}

/*
 * This function is used to get the values of a matrix. It scans values in fractional form 
 * (+|-)value_1/value_2 or in decimal form (+|-)value_1.value_2 where:
 *			+,- is the sign
 *			value_1 is the numerator (fractional form) and whole number (decimal form)
 *	   value_2 is the denominator (fractional form) and decimal value up to 2 digits (decimal form) 
 * Arguments:
 *		matrix:		an array to store the values of the matrix
 *		cur_column, cur_row: the indices where to store the value in the array
 *
 */

float get_values()
{
	const char POS = '+';
	const char NEG = '-';
	const char SLASH = '/';
	const char POINT = '.';
	char sign;
	char dummy;
	float value_1;
	float value_2;
	float value;
	
	scanf("%c", &sign);
	scanf("%f", &value_2);
	scanf("%c", &dummy);
	scanf("%f", &value_2);
	
	if (dummy == SLASH)
	{
		value = value_1/value_2;
	}
	else if (dummy == POINT)
	{
		value = ((value_1 * 100) + value_2)/100;
	}
	
	if (sign == NEG)
	{
		value = -(value);
	}
	
	return value;
	/*	
	 if (dummy == SLASH)
	 {
	 value = (float)(value_1/value_2);
	 }	
	 else if (dummy == POINT)
	 {
	 value = (float)((value_1 * 100)+ value_2)/ 100;
	 }
	 
	 if (sign == POS)
	 {
	 value = value;
	 }
	 else if (sign == NEG)
	 {
	 value = -(value);
	 }
	 */	
	//	matrix[cur_column][cur_row] = value;
}

/*
 * This function displays the resulting matrix derived from the operations.
 * Arguments:
 *		msg:		the message from which the matrix was derived
 *		matrix:	an array where the values of the matrix are stored
 *		column, row: the size of the matrix
 *
 */

void print_matrix(char msg[], float matrix[][MAX_ROW], int column, int row)
{
	int cur_row;
	int cur_column;
	
	printf("\n%s\n", msg);
	printf("Size: %d %d\n", column, row);
	for (cur_row = 0; cur_row < row; cur_row++)
	{
		for (cur_column = 0; cur_column < column; cur_column++)
		{
			if (matrix[cur_column][cur_row] >= 0)
			{
				printf("+%f ", matrix[cur_column][cur_row]);
			}
			else
			{
				printf("%f ", matrix[cur_column][cur_row]);
			}
		}
		printf("\n");
	}
}

/*
 * This function obtains the scalar constant where the value can be any integer (+/-).
 * Arguments:
 * 	value:	where the integer is stored
 *		sign:		where the sign of the integer is stored
 * 	POS:		constant character equivalent to (+) sign
 *		NEG:		constant character equivalent to (-) sign
 * Returns a value.
 *
 */

int input_scalar()
{
	int value;
	char sign;
	const char POS = '+';
	const char NEG = '-';
	
	
	printf("Scalar: ");
	scanf("%c", &sign);
	scanf("%d", &value);		
	
	if (sign == NEG)
	{
		value = -value;
	}
	return value;
}

	