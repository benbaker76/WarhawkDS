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

int readHiScoreValue(int index)
{
	FILE *pFile;
	size_t result;
	char buffer[32];
	int score = 0;
	
	pFile = fopen("/HiScore.dat", "r");
	
	if(pFile == NULL)
		return 0;
		
	result = fseek(pFile, index * 12, SEEK_SET);
	
	if(result != 0)
	{
		fclose(pFile);
		
		return 0;
	}
		
	result = fread(buffer, 1, 7, pFile);
	
	if(result != 7)
	{
		fclose(pFile);
		
		return 0;
	}
	
	buffer[7] = '\0';
	
	score = atoi(buffer);
	
	fclose(pFile);
	
	return score;
}

int readHiScoreName(char *pBuffer, int index)
{
	FILE *pFile;
	size_t result;
	
	pFile = fopen("/HiScore.dat", "r");
	
	if(pFile == NULL)
		return 0;
		
	result = fseek(pFile, index * 12 + 7, SEEK_SET);
	
	if(result != 0)
	{
		fclose(pFile);
		
		return 0;
	}
		
	result = fread(pBuffer, 1, 3, pFile);
	
	if(result != 3)
	{
		fclose(pFile);
		
		return 0;
	}
	
	pBuffer[3] = '\0';
	
	fclose(pFile);
	
	return 1;
}

int writeHiScore(char *pName, int score)
{
	FILE *pFile;
	size_t result;
	char buffer[8];
	char hiScoreBuffer[8];
	int hiScore = 0;
	char hiScoreNewBuffer[8];
	int hiScoreNew = 0;
	int i;
	
	strncpy(hiScoreNewBuffer, pName, 3);
	hiScoreNew = score;
	
	pFile = fopen("/HiScore.dat", "r+");
	
	if(pFile == NULL)
		return 0;
	
	for(i=0; i<10; i++)
	{
		result = fread(buffer, 1, 7, pFile);
		
		if(result != 7)
		{
			fclose(pFile);
			
			return 0;
		}
		
		buffer[7] = '\0';
		
		hiScore = atoi(buffer);
		
		if(hiScoreNew > hiScore)
		{
			result = fread(hiScoreBuffer, 1, 3, pFile);
			
			if(result != 3)
			{
				fclose(pFile);
				
				return 0;
			}
			
			hiScoreBuffer[3] = '\0';
			
			result = fseek(pFile, -10, SEEK_CUR);
			
			if(result != 0)
			{
				fclose(pFile);
				
				return 0;
			}

			sprintf(buffer, "%07d", hiScoreNew);
			
			result = fwrite(buffer, 1, 7, pFile);
			
			if(result != 7)
			{
				fclose(pFile);
				
				return 0;
			
			}
			
			result = fwrite(hiScoreNewBuffer, 1, 3, pFile);
			
			if(result != 3)
			{
				fclose(pFile);
				
				return 0;
			
			}
			
			hiScoreNew = hiScore;
			strncpy(hiScoreNewBuffer, hiScoreBuffer, 3);
			
			result = fseek(pFile, 2, SEEK_CUR);
			
			if(result != 0)
			{
				fclose(pFile);
				
				return 0;
			}
		}
		else
		{
			result = fseek(pFile, 5, SEEK_CUR);
			
			if(result != 0)
			{
				fclose(pFile);
				
				return 0;
			}
		}
	}
	
	fclose(pFile);
	
	return 1;
}