#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Mod Load Order Manager
Программа для управления порядком загрузки модов Darktide
"""

import tkinter as tk
from tkinter import ttk, messagebox, filedialog
import os
import re
from pathlib import Path
from typing import List, Tuple


class ModEntry:
    """Класс для представления записи мода"""
    def __init__(self, name: str, enabled: bool, original_line: str, is_new: bool = False):
        self.name = name
        self.enabled = enabled
        self.original_line = original_line
        self.is_new = is_new  # Флаг для новых модов, найденных при сканировании


class ModLoadOrderManager:
    """Главный класс приложения"""
    
    def __init__(self, root):
        self.root = root
        self.root.title("Mod Load Order Manager")
        self.root.geometry("900x900")
        
        # Путь к файлу mod_load_order.txt
        self.default_path = r"C:\Program Files (x86)\Steam\steamapps\common\Warhammer 40,000 DARKTIDE\mods\mod_load_order.txt"
        self.file_path = self.default_path
        
        # Данные
        self.header_lines: List[str] = []
        self.mod_entries: List[ModEntry] = []
        self.filtered_mod_entries: List[ModEntry] = []
        self.selected_mod_name: str = ""
        
        # Создание интерфейса
        self.create_widgets()
        
        # Загрузка файла при старте
        self.load_file()
    
    def create_widgets(self):
        """Создание элементов интерфейса"""
        # Фрейм для пути к файлу
        path_frame = ttk.Frame(self.root, padding="10")
        path_frame.pack(fill=tk.X)
        
        ttk.Label(path_frame, text="Файл:").pack(side=tk.LEFT, padx=5)
        
        self.path_var = tk.StringVar(value=self.file_path)
        path_entry = ttk.Entry(path_frame, textvariable=self.path_var, width=50)
        path_entry.pack(side=tk.LEFT, fill=tk.X, expand=True, padx=5)
        
        ttk.Button(path_frame, text="Обзор...", command=self.browse_file).pack(side=tk.LEFT, padx=5)
        ttk.Button(path_frame, text="Загрузить", command=self.load_file).pack(side=tk.LEFT, padx=5)
        
        # Основной контейнер для двух панелей
        main_container = ttk.Frame(self.root, padding="10")
        main_container.pack(fill=tk.BOTH, expand=True)
        
        # ========== ЛЕВАЯ ПАНЕЛЬ: Список модов ==========
        left_panel = ttk.Frame(main_container)
        left_panel.pack(side=tk.LEFT, fill=tk.BOTH, expand=True, padx=(0, 5))
        
        # Заголовок списка
        header_frame = ttk.Frame(left_panel)
        header_frame.pack(fill=tk.X, pady=(0, 5))
        
        ttk.Label(header_frame, text="Список модов:", font=("Arial", 10, "bold")).pack(side=tk.LEFT)
        
        # Кнопки управления
        button_frame = ttk.Frame(header_frame)
        button_frame.pack(side=tk.RIGHT)
        
        ttk.Button(button_frame, text="Включить все", command=self.enable_all).pack(side=tk.LEFT, padx=2)
        ttk.Button(button_frame, text="Выключить все", command=self.disable_all).pack(side=tk.LEFT, padx=2)
        ttk.Button(button_frame, text="Обновить список", command=self.scan_and_update).pack(side=tk.LEFT, padx=2)
        
        # Скроллируемый список с чекбоксами
        canvas_frame = ttk.Frame(left_panel)
        canvas_frame.pack(fill=tk.BOTH, expand=True)
        
        # Canvas для скроллинга
        # Используем цвет фона системы вместо белого
        style = ttk.Style()
        bg_color = style.lookup("TFrame", "background")
        if not bg_color:
            bg_color = "SystemButtonFace"  # Цвет по умолчанию для Windows
        self.canvas = tk.Canvas(canvas_frame, bg=bg_color, highlightthickness=0)
        scrollbar = ttk.Scrollbar(canvas_frame, orient="vertical", command=self.canvas.yview)
        self.scrollable_frame = ttk.Frame(self.canvas)
        
        # Функция для обновления ширины scrollable_frame и области прокрутки
        def configure_scroll_region(event=None):
            # Устанавливаем ширину scrollable_frame равной ширине canvas
            canvas_width = self.canvas.winfo_width()
            if canvas_width > 1:  # Избегаем деления на ноль
                self.canvas.itemconfig(self.canvas_window, width=canvas_width)
            # Обновляем область прокрутки
            self.canvas.configure(scrollregion=self.canvas.bbox("all"))
        
        self.scrollable_frame.bind("<Configure>", configure_scroll_region)
        
        # Создаем окно в canvas для scrollable_frame
        self.canvas_window = self.canvas.create_window((0, 0), window=self.scrollable_frame, anchor="nw")
        self.canvas.configure(yscrollcommand=scrollbar.set)
        
        # Привязываем изменение размера canvas к обновлению ширины
        self.canvas.bind("<Configure>", configure_scroll_region)
        
        self.canvas.pack(side=tk.LEFT, fill=tk.BOTH, expand=True)
        scrollbar.pack(side=tk.RIGHT, fill=tk.Y)
        
        # Привязка колесика мыши
        self.canvas.bind_all("<MouseWheel>", self._on_mousewheel)
        
        # ========== ПРАВАЯ СТОРОНА: Контейнер для поиска и информации ==========
        right_container = ttk.Frame(main_container)
        right_container.pack(side=tk.RIGHT, fill=tk.BOTH, padx=(5, 0))
        
        # ========== БЛОК ПОИСКА ==========
        search_panel = ttk.LabelFrame(right_container, text="Поиск", padding="10")
        search_panel.pack(fill=tk.X, pady=(0, 5))
        
        # Поиск/фильтр
        search_frame = ttk.Frame(search_panel)
        search_frame.pack(fill=tk.X)
        
        ttk.Label(search_frame, text="Поиск мода:", font=("Arial", 9, "bold")).pack(anchor=tk.W, pady=(0, 5))
        
        self.search_var = tk.StringVar()
        self.search_var.trace("w", self.on_search_change)
        search_entry = ttk.Entry(search_frame, textvariable=self.search_var)
        search_entry.pack(fill=tk.X, pady=(0, 5))
        
        ttk.Button(search_frame, text="Очистить", command=self.clear_search).pack(fill=tk.X)
        
        # ========== БЛОК ИНФОРМАЦИИ ==========
        right_panel = ttk.LabelFrame(right_container, text="Информация", padding="10")
        right_panel.configure(width=400)
        right_panel.pack_propagate(False)  # Предотвращаем автоматическое изменение размера
        right_panel.pack(fill=tk.BOTH, expand=True)  # Занимает оставшееся пространство
        
        # Статистика
        stats_frame = ttk.Frame(right_panel)
        stats_frame.pack(fill=tk.X, pady=(0, 10))
        
        ttk.Label(stats_frame, text="Статистика:", font=("Arial", 9, "bold")).pack(anchor=tk.W)
        
        self.stats_total_var = tk.StringVar(value="Всего модов: 0")
        self.stats_enabled_var = tk.StringVar(value="Включено: 0")
        self.stats_disabled_var = tk.StringVar(value="Выключено: 0")
        
        ttk.Label(stats_frame, textvariable=self.stats_total_var, font=("Arial", 8)).pack(anchor=tk.W, pady=2)
        ttk.Label(stats_frame, textvariable=self.stats_enabled_var, font=("Arial", 8), foreground="green").pack(anchor=tk.W, pady=2)
        ttk.Label(stats_frame, textvariable=self.stats_disabled_var, font=("Arial", 8), foreground="red").pack(anchor=tk.W, pady=2)
        
        # Разделитель
        ttk.Separator(right_panel, orient=tk.HORIZONTAL).pack(fill=tk.X, pady=10)
        
        # Информация о выбранном моде
        info_frame = ttk.Frame(right_panel)
        info_frame.pack(fill=tk.BOTH, expand=True)
        
        ttk.Label(info_frame, text="Выбранный мод:", font=("Arial", 9, "bold")).pack(anchor=tk.W, pady=(0, 5))
        
        self.selected_mod_var = tk.StringVar(value="Нет выбора")
        mod_info_label = ttk.Label(info_frame, textvariable=self.selected_mod_var, font=("Arial", 8), wraplength=220, justify=tk.LEFT)
        mod_info_label.pack(anchor=tk.W, fill=tk.X)
        
        # Фрейм для кнопок сохранения
        save_frame = ttk.Frame(self.root, padding="10")
        save_frame.pack(fill=tk.X)
        
        ttk.Button(save_frame, text="Сохранить", command=self.save_file, style="Accent.TButton").pack(side=tk.RIGHT, padx=5)
        ttk.Button(save_frame, text="Отменить изменения", command=self.load_file).pack(side=tk.RIGHT, padx=5)
        
        # Статус бар
        self.status_var = tk.StringVar(value="Готов")
        status_bar = ttk.Label(self.root, textvariable=self.status_var, relief=tk.SUNKEN, anchor=tk.W)
        status_bar.pack(side=tk.BOTTOM, fill=tk.X)
    
    def _on_mousewheel(self, event):
        """Обработка прокрутки колесиком мыши"""
        self.canvas.yview_scroll(int(-1 * (event.delta / 120)), "units")
    
    def browse_file(self):
        """Выбор файла через диалог"""
        file_path = filedialog.askopenfilename(
            title="Выберите mod_load_order.txt",
            filetypes=[("Text files", "*.txt"), ("All files", "*.*")],
            initialdir=os.path.dirname(self.file_path) if os.path.exists(self.file_path) else None
        )
        if file_path:
            self.path_var.set(file_path)
            self.file_path = file_path
            self.load_file()
    
    def load_file(self):
        """Загрузка файла mod_load_order.txt"""
        self.file_path = self.path_var.get()
        
        if not os.path.exists(self.file_path):
            messagebox.showerror("Ошибка", f"Файл не найден:\n{self.file_path}")
            self.status_var.set("Ошибка: файл не найден")
            return
        
        try:
            with open(self.file_path, 'r', encoding='utf-8') as f:
                lines = f.readlines()
            
            # Очистка данных
            self.header_lines = []
            self.mod_entries = []
            
            # Разделение на заголовок и моды
            in_header = True
            for line in lines:
                stripped = line.rstrip('\n\r')
                
                # Заголовок - строки начинающиеся с "-- " (с пробелом после) или пустые строки в начале
                if in_header:
                    if stripped.startswith("-- "):
                        # Комментарий заголовка (с пробелом после --)
                        self.header_lines.append(line)
                        continue
                    elif stripped == "" and len(self.header_lines) > 0:
                        # Пустая строка в заголовке
                        self.header_lines.append(line)
                        continue
                    else:
                        # Первая не-заголовочная строка - начинаем обработку модов
                        in_header = False
                
                # Пропускаем пустые строки после заголовка
                if not stripped:
                    continue
                
                # Обработка модов
                if stripped.startswith("--"):
                    # Закомментированный мод (начинается с --, но без пробела или с именем мода)
                    mod_name = stripped[2:].strip()
                    # Проверяем, что это действительно имя мода (содержит буквы/цифры)
                    if mod_name and any(c.isalnum() for c in mod_name):
                        self.mod_entries.append(ModEntry(mod_name, False, stripped))
                else:
                    # Активный мод (не начинается с --)
                    mod_name = stripped.strip()
                    if mod_name:  # Проверяем, что строка не пустая
                        self.mod_entries.append(ModEntry(mod_name, True, stripped))
            
            # Сканирование папки модов для поиска новых модов
            self.scan_mods_directory()
            
            # Обновление интерфейса
            self.update_mod_list()
            self.update_statistics()
            new_mods_count = sum(1 for m in self.mod_entries if m.is_new)
            if new_mods_count > 0:
                self.status_var.set(f"Загружено модов: {len(self.mod_entries)} (новых: {new_mods_count})")
            else:
                self.status_var.set(f"Загружено модов: {len(self.mod_entries)}")
            
        except Exception as e:
            messagebox.showerror("Ошибка", f"Не удалось загрузить файл:\n{str(e)}")
            self.status_var.set(f"Ошибка: {str(e)}")
    
    def scan_mods_directory(self):
        """Сканирование папки модов для поиска модов, отсутствующих в списке"""
        try:
            # Определяем путь к папке mods (та же директория, где находится mod_load_order.txt)
            mods_dir = os.path.dirname(self.file_path)
            if not os.path.exists(mods_dir):
                return
            
            # Получаем список существующих модов из файла
            existing_mod_names = {mod.name for mod in self.mod_entries}
            
            # Сканируем папки в директории mods
            new_mods = []
            for item in os.listdir(mods_dir):
                item_path = os.path.join(mods_dir, item)
                
                # Пропускаем файлы, ищем только папки
                if not os.path.isdir(item_path):
                    continue
                
                # Пропускаем служебные папки
                if item.startswith('_') or item.lower() in ['base', 'dmf']:
                    continue
                
                # Проверяем наличие файла .mod в папке
                mod_file = os.path.join(item_path, f"{item}.mod")
                if os.path.exists(mod_file):
                    # Если мод не найден в списке, добавляем его
                    if item not in existing_mod_names:
                        new_mods.append(item)
            
            # Добавляем новые моды в конец списка (выключенными по умолчанию)
            for mod_name in sorted(new_mods):
                self.mod_entries.append(ModEntry(
                    name=mod_name,
                    enabled=False,  # Новые моды по умолчанию выключены
                    original_line=f"--{mod_name}",  # По умолчанию закомментированы
                    is_new=True
                ))
            
        except Exception as e:
            # Не показываем ошибку пользователю, просто логируем в статус
            self.status_var.set(f"Предупреждение: не удалось просканировать папку модов: {str(e)}")
    
    def scan_and_update(self):
        """Сканирование папки модов и обновление списка"""
        old_count = len(self.mod_entries)
        self.scan_mods_directory()
        new_count = len(self.mod_entries) - old_count
        
        if new_count > 0:
            # Обновляем интерфейс
            search_text = self.search_var.get() if hasattr(self, 'search_var') else ""
            self.update_mod_list(filter_text=search_text)
            self.update_statistics()
            messagebox.showinfo("Обновление", f"Найдено новых модов: {new_count}")
        else:
            messagebox.showinfo("Обновление", "Новых модов не найдено")
    
    def update_mod_list(self, filter_text: str = None):
        """Обновление списка модов в интерфейсе"""
        # Очистка существующих виджетов
        for widget in self.scrollable_frame.winfo_children():
            widget.destroy()
        
        # Получаем текст фильтра
        if filter_text is None:
            if hasattr(self, 'search_var'):
                filter_text = self.search_var.get()
            else:
                filter_text = ""
        
        # Фильтрация модов
        if filter_text:
            filter_lower = filter_text.lower()
            self.filtered_mod_entries = [
                mod for mod in self.mod_entries 
                if filter_lower in mod.name.lower()
            ]
        else:
            self.filtered_mod_entries = self.mod_entries.copy()
        
        # Создание чекбоксов для каждого мода
        self.checkbox_vars = {}
        for i, mod_entry in enumerate(self.filtered_mod_entries):
            var = tk.BooleanVar(value=mod_entry.enabled)
            self.checkbox_vars[mod_entry.name] = var
            
            frame = ttk.Frame(self.scrollable_frame)
            frame.pack(fill=tk.X, padx=5, pady=2)
            
            # Чекбокс с обработкой клика для выбора
            checkbox_text = mod_entry.name
            checkbox = ttk.Checkbutton(
                frame,
                text=checkbox_text,
                variable=var,
                command=lambda name=mod_entry.name: self.on_checkbox_change(name)
            )
            checkbox.pack(side=tk.LEFT)
            
            # Метка "NEW" для новых модов
            if mod_entry.is_new:
                new_label = ttk.Label(
                    frame,
                    text="[NEW]",
                    foreground="blue",
                    font=("Arial", 7, "bold")
                )
                new_label.pack(side=tk.LEFT, padx=(2, 0))
            
            # Обработка клика по фрейму для выбора мода
            def on_frame_click(event, name=mod_entry.name):
                self.select_mod(name)
            
            frame.bind("<Button-1>", on_frame_click)
            checkbox.bind("<Button-1>", lambda e, name=mod_entry.name: self.select_mod(name))
            
            # Индикатор статуса (обновляется динамически)
            status_text = tk.StringVar(value="✓" if mod_entry.enabled else "✗")
            status_color = "green" if mod_entry.enabled else "red"
            status_label = ttk.Label(
                frame,
                textvariable=status_text,
                foreground=status_color
            )
            status_label.pack(side=tk.LEFT, padx=5)
            
            # Сохраняем ссылку на переменную для обновления
            mod_entry.status_var = status_text
            mod_entry.status_label = status_label
            
            # Выделение выбранного мода (визуально через цвет фона)
            if mod_entry.name == self.selected_mod_name:
                frame.configure(relief=tk.SUNKEN, borderwidth=1)
        
        # Обновление статистики
        self.update_statistics()
    
    def on_checkbox_change(self, mod_name: str):
        """Обработка изменения состояния чекбокса"""
        enabled = self.checkbox_vars[mod_name].get()
        # Обновляем статус в данных
        for mod_entry in self.mod_entries:
            if mod_entry.name == mod_name:
                mod_entry.enabled = enabled
                # Обновляем визуальный индикатор статуса, если он существует
                if hasattr(mod_entry, 'status_var'):
                    mod_entry.status_var.set("✓" if enabled else "✗")
                if hasattr(mod_entry, 'status_label'):
                    mod_entry.status_label.configure(foreground="green" if enabled else "red")
                break
        # Обновляем статистику
        self.update_statistics()
        # Обновляем информацию о выбранном моде, если он был выбран
        if self.selected_mod_name == mod_name:
            self.select_mod(mod_name)
    
    def select_mod(self, mod_name: str):
        """Выбор мода для отображения информации"""
        self.selected_mod_name = mod_name
        # Ищем мод в основном списке
        mod_entry = next((m for m in self.mod_entries if m.name == mod_name), None)
        if mod_entry:
            # Получаем актуальное значение enabled из чекбокса, если он существует
            if hasattr(self, 'checkbox_vars') and mod_name in self.checkbox_vars:
                actual_enabled = self.checkbox_vars[mod_name].get()
                # Синхронизируем с данными
                mod_entry.enabled = actual_enabled
            else:
                actual_enabled = mod_entry.enabled
            
            status = "Включен" if actual_enabled else "Выключен"
            info_text = f"{mod_name}\nСтатус: {status}"
            if mod_entry.is_new:
                info_text += "\n⚠ Новый мод (не был в файле)"
            self.selected_mod_var.set(info_text)
        else:
            self.selected_mod_var.set("Нет выбора")
    
    def update_statistics(self):
        """Обновление статистики в правой панели"""
        total = len(self.mod_entries)
        enabled = sum(1 for m in self.mod_entries if m.enabled)
        disabled = total - enabled
        
        self.stats_total_var.set(f"Всего модов: {total}")
        self.stats_enabled_var.set(f"Включено: {enabled}")
        self.stats_disabled_var.set(f"Выключено: {disabled}")
    
    def on_search_change(self, *args):
        """Обработка изменения текста поиска"""
        if hasattr(self, 'search_var'):
            search_text = self.search_var.get()
            self.update_mod_list(filter_text=search_text)
    
    def clear_search(self):
        """Очистка поля поиска"""
        if hasattr(self, 'search_var'):
            self.search_var.set("")
            self.update_mod_list()
    
    def enable_all(self):
        """Включить все моды"""
        for var in self.checkbox_vars.values():
            var.set(True)
        for mod_entry in self.mod_entries:
            mod_entry.enabled = True
        search_text = self.search_var.get() if hasattr(self, 'search_var') else ""
        self.update_mod_list(filter_text=search_text)
    
    def disable_all(self):
        """Выключить все моды"""
        for var in self.checkbox_vars.values():
            var.set(False)
        for mod_entry in self.mod_entries:
            mod_entry.enabled = False
        search_text = self.search_var.get() if hasattr(self, 'search_var') else ""
        self.update_mod_list(filter_text=search_text)
    
    def save_file(self):
        """Сохранение изменений в файл"""
        if not self.mod_entries:
            messagebox.showwarning("Предупреждение", "Нет модов для сохранения")
            return
        
        try:
            # Подготовка содержимого
            content_lines = []
            
            # Добавляем заголовок
            content_lines.extend(self.header_lines)
            
            # Добавляем моды
            for mod_entry in self.mod_entries:
                # Обновляем статус из чекбоксов
                if mod_entry.name in self.checkbox_vars:
                    mod_entry.enabled = self.checkbox_vars[mod_entry.name].get()
                
                # Сбрасываем флаг "новый" после сохранения
                if mod_entry.is_new:
                    mod_entry.is_new = False
                
                if mod_entry.enabled:
                    content_lines.append(mod_entry.name + "\n")
                else:
                    content_lines.append("--" + mod_entry.name + "\n")
            
            # Сохранение файла
            with open(self.file_path, 'w', encoding='utf-8') as f:
                f.writelines(content_lines)
            
            messagebox.showinfo("Успех", "Файл успешно сохранен!")
            self.status_var.set("Файл сохранен")
            
            # Перезагрузка для синхронизации
            self.load_file()
            
        except Exception as e:
            messagebox.showerror("Ошибка", f"Не удалось сохранить файл:\n{str(e)}")
            self.status_var.set(f"Ошибка сохранения: {str(e)}")


def main():
    """Точка входа в приложение"""
    root = tk.Tk()
    app = ModLoadOrderManager(root)
    root.mainloop()


if __name__ == "__main__":
    main()
