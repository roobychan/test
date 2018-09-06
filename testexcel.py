from openpyxl import Workbook

wb = Workbook()
filename = 'test.xlsx'

ws1 = wb.active

ls = [1,2,2,3,4,5,6,4]

ws1.append(ls)
wb.save(filename=filename)