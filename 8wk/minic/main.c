#include <stdio.h> 
#include "ast.h"

int yyparse(void);
extern Node *root;


// 파일이름은 여기에서 확장자 바꾸면 됨


int main(int argc, char **argv){
  if(yyparse()==0){ // 파싱 성공 했음을 의미
    printf("=== AST ===\n");
    print_ast(root, 0);
    free_ast(root);
    return 0;// 문제없음
  }
  return 1; // 파싱 실패 시
  
}
