#!/usr/bin/env python3
"""
Демонстрація розширеного інтерпретатора
Завдання 2 - goit-cs-hw-01
"""

from interpreter import Lexer, Parser, Interpreter, print_ast

def demo_basic_operations():
    """Демонстрація базових операцій"""
    print("=" * 60)
    print("ДЕМОНСТРАЦІЯ БАЗОВИХ ОПЕРАЦІЙ")
    print("=" * 60)
    
    expressions = [
        "2 + 3",      # Додавання
        "5 - 1",      # Віднімання  
        "4 * 3",      # Множення
        "10 / 2",     # Ділення
    ]
    
    for expr in expressions:
        lexer = Lexer(expr)
        parser = Parser(lexer)
        interpreter = Interpreter(parser)
        result = interpreter.interpret()
        print(f"{expr:15} = {result}")

def demo_operator_precedence():
    """Демонстрація пріоритету операцій"""
    print("\n" + "=" * 60)
    print("ДЕМОНСТРАЦІЯ ПРІОРИТЕТУ ОПЕРАЦІЙ")
    print("=" * 60)
    
    expressions = [
        ("2 + 3 * 4", "Множення має вищий пріоритет"),
        ("(2 + 3) * 4", "Дужки мають найвищий пріоритет"),
        ("10 - 2 * 3", "Множення виконується перше"),
        ("(10 - 2) * 3", "Дужки змінюють порядок"),
        ("14 / 2 + 3", "Ділення має вищий пріоритет за додавання"),
        ("14 / (2 + 3)", "Дужки змінюють порядок обчислення"),
    ]
    
    for expr, explanation in expressions:
        lexer = Lexer(expr)
        parser = Parser(lexer)
        interpreter = Interpreter(parser)
        result = interpreter.interpret()
        print(f"{expr:20} = {result:8} ({explanation})")

def demo_complex_expressions():
    """Демонстрація складних виразів"""
    print("\n" + "=" * 60)
    print("ДЕМОНСТРАЦІЯ СКЛАДНИХ ВИРАЗІВ")
    print("=" * 60)
    
    expressions = [
        "1 + 2 * 3 - 4 / 2",
        "2 * (3 + 4) - 6 / 2",
        "(10 + 5) / (3 * 1)",
        "3 * (2 + 4) / (6 - 4)",
        "((2 + 3) * 4) / (10 - 5)",
    ]
    
    for expr in expressions:
        lexer = Lexer(expr)
        parser = Parser(lexer)
        interpreter = Interpreter(parser)
        result = interpreter.interpret()
        print(f"{expr:25} = {result}")

def demo_ast_visualization():
    """Демонстрація візуалізації AST"""
    print("\n" + "=" * 60)
    print("ДЕМОНСТРАЦІЯ AST (Abstract Syntax Tree)")
    print("=" * 60)
    
    expression = "(2 + 3) * 4"
    print(f"Вираз: {expression}")
    print("AST:")
    
    lexer = Lexer(expression)
    parser = Parser(lexer)
    tree = parser.expr()
    print_ast(tree)
    
    # Обчислюємо результат
    lexer = Lexer(expression)
    parser = Parser(lexer)
    interpreter = Interpreter(parser)
    result = interpreter.interpret()
    print(f"\nРезультат: {result}")

def demo_error_handling():
    """Демонстрація обробки помилок"""
    print("\n" + "=" * 60)
    print("ДЕМОНСТРАЦІЯ ОБРОБКИ ПОМИЛОК")
    print("=" * 60)
    
    error_cases = [
        "10 / 0",          # Ділення на нуль
        "2 + * 3",         # Неправильний синтаксис
        "(2 + 3",          # Незакрита дужка
        "2 + 3)",          # Зайва дужка
        "2 @ 3",           # Невідомий оператор
    ]
    
    for expr in error_cases:
        try:
            lexer = Lexer(expr)
            parser = Parser(lexer)
            interpreter = Interpreter(parser)
            result = interpreter.interpret()
            print(f"{expr:15} = {result}")
        except Exception as e:
            print(f"{expr:15} = ПОМИЛКА: {type(e).__name__}: {e}")

def main():
    """Головна демонстраційна функція"""
    print("РОЗШИРЕНИЙ АРИФМЕТИЧНИЙ ІНТЕРПРЕТАТОР")
    print("Завдання 2 - Інтерпретатори та компілятори")
    print("Підтримує: числа, +, -, *, /, дужки ()")
    
    demo_basic_operations()
    demo_operator_precedence()
    demo_complex_expressions()
    demo_ast_visualization()
    demo_error_handling()
    
    print("\n" + "=" * 60)
    print("ВИСНОВОК")
    print("=" * 60)
    print("✅ Додано підтримку множення (*) та ділення (/)")
    print("✅ Додано підтримку дужок () для зміни пріоритету")
    print("✅ Реалізована правильна ієрархія операцій")
    print("✅ Додана обробка помилок (ділення на нуль, синтаксис)")
    print("✅ Інтерпретатор успішно обробляє складні вирази")
    print("\nПриклад з завдання: (2 + 3) * 4 = 20 ✅")

if __name__ == "__main__":
    main()
