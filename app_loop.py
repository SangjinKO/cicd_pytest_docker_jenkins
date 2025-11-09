import time

def add(a, b):
    return a + b

def subtract(a, b):
    return a - b

if __name__ == "__main__":
    inputs = [(10, 5), (9, 6), (8, 7), (6, 8), (4, 9)]
    i = 0
    while True:
        a, b = inputs[i]
        print(f"Add: {a} + {b} = {add(a, b)}")
        print(f"Subtract: {a} - {b} = {subtract(a, b)}")
        print("-" * 30)
        time.sleep(2)

        i = (i + 1) % len(inputs)  # 마지막까지 갔다가 다시 처음으로
