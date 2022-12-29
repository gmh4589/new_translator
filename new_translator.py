# -*- coding:utf-8 -*-
from kivy.app import App
from kivy.factory import Factory
from kivy.lang import Builder
from kivy.uix.popup import Popup
from kivy.uix.screenmanager import ScreenManager, Screen
from tkinter import filedialog as fd

import openpyxl

sss = 0

# Загружает конфиг интерфейса
Builder.load_file('new_translator.kv')

class MainScreen(Screen):

    values = []
    filename = ''
    sheet = ''
    readData = ''
    sss = 0

    def __init__(self, **kwargs):
        super().__init__(**kwargs)

    def fileOpen(self):

        filetypes = (
            ('Файлы Excel', '*.xlsx'),
            ('All files', '*.*')
        )

        self.filename = fd.askopenfilename(
            title = 'Выберите XLSX файл',
            initialdir = '/',
            filetypes = filetypes)

        print(self.filename)

        if self.filename != '':
            self.readData = openpyxl.load_workbook(self.filename, data_only = True)
            self.sheet = self.readData.active
            rows = self.sheet.max_row
            cols = self.sheet.max_column

            for row in range(1, rows):
                for col in range(1, cols):
                    cell = self.sheet.cell(row = row, column = col).value

                    if cell == 'dialog':
                        val = [self.sheet.cell(row = row + 1, column = col).value, '', row + 1, col]
                        self.values.append(val)

            print(self.values)

            self.ids['originalTXT'].text = str(self.values[0][0])
            self.ids['newTXT'].text = str(self.values[0][0])
            self.ids['rdyLabel'].text = '1/' + str(len(self.values)) + ' готово'
            self.ids['longLabel'].text = str(len(self.values[0][0])) + ' символов'
            self.ids['percentLabel'].text = str((100 / len(self.values) * sss + 1))[:4] + ' %'

    def writeFile(self):

        for cell in range(len(self.values)):
            self.sheet.cell(row = int(self.values[cell][2]),
                            column = int(self.values[cell][3])).value\
                = self.values[cell][1]

        self.readData.save(self.filename)
        Factory.SavedPopup().open()

    def nextString(self, step = '+'):

        global sss

        def setString():
            self.values[sss][1] = self.ids['newTXT'].text
            print(self.values[sss][1])

        try:
            setString()
            if step == '+': sss += 1
            elif step == '-':
                if sss != 0: sss -= 1
                else: Factory.EOFPopup().open()

            #print(self.values)

            self.ids['originalTXT'].text = str(self.values[sss][0])
            if str(self.values[sss][1]) == '': self.ids['newTXT'].text = str(self.values[sss][0])
            else: self.ids['newTXT'].text = str(self.values[sss][1])
            self.ids['rdyLabel'].text = str(sss + 1) + '/' + str(len(self.values)) + ' готово'
            self.ids['longLabel'].text = str(len(self.values[sss][0])) + ' символов'
            self.ids['percentLabel'].text = str((100 / len(self.values) * sss))[:4] + ' %'

        except IndexError: Factory.EOFPopup().open()

    def reFresh(self):
        self.ids['newTXT'].text = self.ids['originalTXT'].text

    def findBTN(self): pass

class NewTranslatorApp(App):

    # Создаёт  интерфейс
    def build(self):
        sm = ScreenManager()
        sm.add_widget(MainScreen(name = 'main'))

        return sm

NewTranslatorApp().run()
