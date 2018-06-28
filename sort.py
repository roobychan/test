import random

numberList = []
numberList = list(range(1, 100000))
# print(numberList)

random.shuffle(numberList)

# print(numberList)


def swap(sList, left, right):
    tValue = sList[left]
    sList[left] = sList[right]
    sList[right] = tValue


def quickSort(sList, low, high):
    if low >= high:
        return

    mid = part(sList, low, high)

    quickSort(sList, low, mid - 1)
    quickSort(sList, mid, high)


def part(sList, low, high):
    cValue = sList[low]
    left = low + 1
    right = high
    while True:
        while left < high:
            if sList[left] > cValue:
                break
            left += 1
        while right > low:
            if sList[right] < cValue:
                break
            right -= 1
        if left >= right:
            break
        swap(sList, left, right)
    swap(sList, low, right)
    return left


print(numberList)
quickSort(numberList, 0, len(numberList) - 1)
print(numberList)
