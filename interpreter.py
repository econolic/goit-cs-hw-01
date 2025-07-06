# Розширений інтерпретатор з підтримкою множення, ділення та дужок
# Основа: https://github.com/goitacademy/Computer-Systems-and-Their-Fundamentals/tree/main/Chapter%2002

class LexicalError(Exception):
    pass


class ParsingError(Exception):
    pass


class TokenType:
    INTEGER = "INTEGER"
    PLUS = "PLUS"
    MINUS = "MINUS"
    MUL = "MUL"        # Нова операція множення
    DIV = "DIV"        # Нова операція ділення  
    LPAREN = "LPAREN"  # Ліва дужка (
    RPAREN = "RPAREN"  # Права дужка )
    EOF = "EOF"        # Означає кінець вхідного рядка


class Token:
    def __init__(self, type, value):
        self.type = type
        self.value = value

    def __str__(self):
        return f"Token({self.type}, {repr(self.value)})"

    def __repr__(self):
        return self.__str__()


class Lexer:
    def __init__(self, text):
        self.text = text
        self.pos = 0
        self.current_char = self.text[self.pos]

    def advance(self):
        """Переміщуємо 'вказівник' на наступний символ вхідного рядка"""
        self.pos += 1
        if self.pos > len(self.text) - 1:
            self.current_char = None  # Означає кінець введення
        else:
            self.current_char = self.text[self.pos]

    def skip_whitespace(self):
        """Пропускаємо пробільні символи."""
        while self.current_char is not None and self.current_char.isspace():
            self.advance()

    def integer(self):
        """Повертаємо ціле число, зібране з послідовності цифр."""
        result = ""
        while self.current_char is not None and self.current_char.isdigit():
            result += self.current_char
            self.advance()
        return int(result)

    def get_next_token(self):
        """Лексичний аналізатор, що розбиває вхідний рядок на токени."""
        while self.current_char is not None:
            if self.current_char.isspace():
                self.skip_whitespace()
                continue

            if self.current_char.isdigit():
                return Token(TokenType.INTEGER, self.integer())

            if self.current_char == "+":
                self.advance()
                return Token(TokenType.PLUS, "+")

            if self.current_char == "-":
                self.advance()
                return Token(TokenType.MINUS, "-")

            # Нові токени для множення та ділення
            if self.current_char == "*":
                self.advance()
                return Token(TokenType.MUL, "*")

            if self.current_char == "/":
                self.advance()
                return Token(TokenType.DIV, "/")

            # Нові токени для дужок
            if self.current_char == "(":
                self.advance()
                return Token(TokenType.LPAREN, "(")

            if self.current_char == ")":
                self.advance()
                return Token(TokenType.RPAREN, ")")

            raise LexicalError(f"Помилка лексичного аналізу: невідомий символ '{self.current_char}'")

        return Token(TokenType.EOF, None)


###############################################################################
#                                                                             #
#  AST (Abstract Syntax Tree) - Абстрактне синтаксичне дерево                #
#                                                                             #
###############################################################################

class AST:
    pass


class BinOp(AST):
    def __init__(self, left, op, right):
        self.left = left
        self.op = op
        self.right = right


class Num(AST):
    def __init__(self, token):
        self.token = token
        self.value = token.value


###############################################################################
#                                                                             #
#  PARSER - Синтаксичний аналізатор                                          #
#                                                                             #
###############################################################################

class Parser:
    def __init__(self, lexer):
        self.lexer = lexer
        self.current_token = self.lexer.get_next_token()

    def error(self):
        raise ParsingError("Помилка синтаксичного аналізу")

    def eat(self, token_type):
        """
        Порівнюємо поточний токен з очікуваним токеном і, якщо вони збігаються,
        'поглинаємо' його і переходимо до наступного токена.
        """
        if self.current_token.type == token_type:
            self.current_token = self.lexer.get_next_token()
        else:
            self.error()

    def factor(self):
        """
        factor : INTEGER | LPAREN expr RPAREN
        
        Обробляє числа та вирази в дужках
        """
        token = self.current_token
        if token.type == TokenType.INTEGER:
            self.eat(TokenType.INTEGER)
            return Num(token)
        elif token.type == TokenType.LPAREN:
            self.eat(TokenType.LPAREN)
            node = self.expr()
            self.eat(TokenType.RPAREN)
            return node

    def term(self):
        """
        term : factor ((MUL | DIV) factor)*
        
        Обробляє множення та ділення (вищий пріоритет)
        """
        node = self.factor()

        while self.current_token.type in (TokenType.MUL, TokenType.DIV):
            token = self.current_token
            if token.type == TokenType.MUL:
                self.eat(TokenType.MUL)
            elif token.type == TokenType.DIV:
                self.eat(TokenType.DIV)

            node = BinOp(left=node, op=token, right=self.factor())

        return node

    def expr(self):
        """
        expr : term ((PLUS | MINUS) term)*
        
        Обробляє додавання та віднімання (нижчий пріоритет)
        """
        node = self.term()

        while self.current_token.type in (TokenType.PLUS, TokenType.MINUS):
            token = self.current_token
            if token.type == TokenType.PLUS:
                self.eat(TokenType.PLUS)
            elif token.type == TokenType.MINUS:
                self.eat(TokenType.MINUS)

            node = BinOp(left=node, op=token, right=self.term())

        return node


###############################################################################
#                                                                             #
#  INTERPRETER - Інтерпретатор                                               #
#                                                                             #
###############################################################################

class Interpreter:
    def __init__(self, parser):
        self.parser = parser

    def visit_BinOp(self, node):
        """Обробка бінарних операцій"""
        if node.op.type == TokenType.PLUS:
            return self.visit(node.left) + self.visit(node.right)
        elif node.op.type == TokenType.MINUS:
            return self.visit(node.left) - self.visit(node.right)
        elif node.op.type == TokenType.MUL:
            return self.visit(node.left) * self.visit(node.right)
        elif node.op.type == TokenType.DIV:
            right_val = self.visit(node.right)
            if right_val == 0:
                raise ZeroDivisionError("Ділення на нуль!")
            return self.visit(node.left) / right_val

    def visit_Num(self, node):
        """Обробка чисел"""
        return node.value

    def interpret(self):
        """Головний метод інтерпретації"""
        tree = self.parser.expr()
        return self.visit(tree)

    def visit(self, node):
        """Диспетчер для відвідування вузлів AST"""
        method_name = "visit_" + type(node).__name__
        visitor = getattr(self, method_name, self.generic_visit)
        return visitor(node)

    def generic_visit(self, node):
        raise Exception(f"Немає методу visit_{type(node).__name__}")


###############################################################################
#                                                                             #
#  UTILITIES - Допоміжні функції                                             #
#                                                                             #
###############################################################################

def print_ast(node, level=0):
    """Виводить AST у зрозумілому форматі"""
    indent = "  " * level
    if isinstance(node, Num):
        print(f"{indent}Num({node.value})")
    elif isinstance(node, BinOp):
        print(f"{indent}BinOp:")
        print(f"{indent}  left: ")
        print_ast(node.left, level + 2)
        print(f"{indent}  op: {node.op.type}")
        print(f"{indent}  right: ")
        print_ast(node.right, level + 2)
    else:
        print(f"{indent}Unknown node type: {type(node)}")


def test_interpreter():
    """Функція для тестування інтерпретатора"""
    test_cases = [
        "2 + 3",
        "5 - 1", 
        "4 * 3",
        "10 / 2",
        "2 + 3 * 4",
        "(2 + 3) * 4",
        "2 * (3 + 4)",
        "10 - 2 * 3",
        "(10 - 2) * 3", 
        "14 / 2 + 3",
        "14 / (2 + 3)",
        "1 + 2 * 3 - 4 / 2"
    ]
    
    print("=" * 50)
    print("ТЕСТУВАННЯ РОЗШИРЕНОГО ІНТЕРПРЕТАТОРА")
    print("=" * 50)
    
    for expression in test_cases:
        try:
            lexer = Lexer(expression)
            parser = Parser(lexer)
            interpreter = Interpreter(parser)
            result = interpreter.interpret()
            print(f"{expression:20} = {result}")
        except Exception as e:
            print(f"{expression:20} = ПОМИЛКА: {e}")


def main():
    """Головна функція для інтерактивного використання"""
    print("Розширений арифметичний інтерпретатор")
    print("Підтримує: +, -, *, /, дужки ()")
    print("Введіть 'exit' для виходу")
    print("Введіть 'test' для запуску тестів")
    print("-" * 40)
    
    while True:
        try:
            text = input('Введіть вираз: ')
            if text.lower() == "exit":
                print("Вихід із програми.")
                break
            elif text.lower() == "test":
                test_interpreter()
                continue
            elif text.lower() == "ast":
                # Додаткова функція для перегляду AST
                expr = input('Введіть вираз для показу AST: ')
                lexer = Lexer(expr)
                parser = Parser(lexer)
                tree = parser.expr()
                print("AST:")
                print_ast(tree)
                continue
                
            lexer = Lexer(text)
            parser = Parser(lexer)
            interpreter = Interpreter(parser)
            result = interpreter.interpret()
            print(f"Результат: {result}")
            
        except Exception as e:
            print(f"Помилка: {e}")


if __name__ == "__main__":
    main()
