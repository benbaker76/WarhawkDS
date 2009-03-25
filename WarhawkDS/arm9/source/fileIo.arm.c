#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <sys/stat.h>

#include "efs_lib.h"    // include EFS lib

char *pfileBuffer = NULL;
FILE *pFileStream = NULL;

int readFile(char *fileName)
{ 
	FILE *pFile;
	struct stat fileStat;
	size_t result;
	
	if(pfileBuffer != NULL)
		free(pfileBuffer);

	pFile = fopen(fileName, "rb");
	
	if(pFile == NULL)
		return 0;

	if(fstat(pFile->_file, &fileStat) != 0)
	{
		fclose(pFile);
		return 0;
	}

	pfileBuffer = (char *) malloc(fileStat.st_size);
	
	if(pfileBuffer == NULL)
	{
		fclose(pFile);
		return 0;
	}

	result = fread(pfileBuffer, 1, fileStat.st_size, pFile);
	
	if(result != fileStat.st_size)
	{
		fclose(pFile);
		return 0;
	}

	fclose(pFile);
	
	return fileStat.st_size;
}

int readFileBuffer(char *fileName, char *pBuffer)
{ 
	FILE *pFile;
	struct stat fileStat;
	size_t result;
	
	if(pfileBuffer != NULL)
		free(pfileBuffer);

	pFile = fopen(fileName, "rb");
	
	if(pFile == NULL)
		return 0;

	if(fstat(pFile->_file, &fileStat) != 0)
	{
		fclose(pFile);
		return 0;
	}

	result = fread(pBuffer, 1, fileStat.st_size, pFile);
	
	if(result != fileStat.st_size)
	{
		fclose(pFile);
		return 0;
	}

	fclose(pFile);
	
	return fileStat.st_size;
}

int writeFileBuffer(char *fileName, char *pBuffer)
{ 
	FILE *pFile;
	struct stat fileStat;
	size_t result;
	
	if(pfileBuffer != NULL)
		free(pfileBuffer);

	pFile = fopen(fileName, "wb");
	
	if(pFile == NULL)
		return 0;

	if(fstat(pFile->_file, &fileStat) != 0)
	{
		fclose(pFile);
		return 0;
	}

	result = fwrite(pBuffer, 1, fileStat.st_size, pFile);
	
	if(result != fileStat.st_size)
	{
		fclose(pFile);
		return 0;
	}

	fclose(pFile);
	
	return fileStat.st_size;
}

/* int readFileStream(char *fileName, char *pBuffer, int pos, int size)
{ 
	size_t result;
	
	if(pFileStream == NULL)
		pFileStream = fopen(fileName, "rb");
	
	if (pFileStream == NULL)
		return 0;
	
	result = fseek(pFileStream, pos, SEEK_SET);
	
	if(result != 0)
	{
		fclose(pFileStream);
		return 0;
	}

	result = fread(pBuffer, 1, size, pFileStream);
	
	if(result != size)
	{
		fclose(pFileStream);
		return 0;
	}

	//fclose(pFile);
	
	return 1;
} */

int initFileStream(char *fileName)
{
	struct stat fileStat;
	
	if(pFileStream != NULL)
		fclose(pFileStream);
	
	pFileStream = fopen(fileName, "rb");
	
	if(pFileStream == NULL)
		return 0;

	if(fstat(pFileStream->_file, &fileStat) != 0)
	{
		fclose(pFileStream);
		
		return 0;
	}

	return fileStat.st_size;
}

int readFileStream(char *pBuffer, int size)
{ 
	size_t result;
	
	if(pFileStream == NULL)
		return 0;
	
	result = fread(pBuffer, 1, size, pFileStream);
	
	if(result != size)
		return result;
	
	return result;
}

int resetFileStream()
{ 
	size_t result;
	
	if(pFileStream == NULL)
		return 0;
	
	result = fseek(pFileStream, 0, SEEK_SET);
	
	if(result != 0)
		return 0;
	
	return 1;
}

int readFileSize(char *fileName)
{
	struct stat fileStat;
	size_t result;
	
	result = stat(fileName, &fileStat);
	
	if(result != 0)
		return 0;
		
	return fileStat.st_size;
}
