#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Mod Load Order Manager
Программа для управления порядком загрузки модов Darktide
"""

import tkinter as tk
from tkinter import ttk, messagebox, filedialog, simpledialog
import os
import re
import json
from pathlib import Path
from typing import List, Tuple, Dict


class ModEntry:
    """Класс для представления записи мода"""
    def __init__(self, name: str, enabled: bool, original_line: str, is_new: bool = False, order_index: int = 0):
        self.name = name
        self.enabled = enabled
        self.original_line = original_line
        self.is_new = is_new  # Флаг для новых модов, найденных при сканировании
        self.order_index = order_index  # Порядковый номер из файла (для сортировки по умолчанию)


class ModLoadOrderManager:
    """Главный класс приложения"""
    
    def __init__(self, root):
        self.root = root
        self.root.title("Mod Load Order Manager")
        self.root.geometry("980x900")
        
        # Путь к файлу mod_load_order.txt
        self.default_path = r"C:\Program Files (x86)\Steam\steamapps\common\Warhammer 40,000 DARKTIDE\mods\mod_load_order.txt"
        self.file_path = self.default_path
        
        # Данные
        self.header_lines: List[str] = []
        self.mod_entries: List[ModEntry] = []
        self.filtered_mod_entries: List[ModEntry] = []
        self.selected_mod_name: str = ""
        self.sort_type: str = "name"  # Тип сортировки: "name", "status", "new_first"
        
        # Система профилей (инициализируем перед вызовом init_profiles_directory)
        self.saved_state: dict = None  # Сохраненное состояние перед переключением
        self.profiles_dir = None  # Путь к папке профилей
        
        # Инициализация папки профилей
        self.init_profiles_directory()
        
        # Создание интерфейса
        self.create_widgets()
        
        # Загрузка файла при старте
        self.load_file()
    
    def init_profiles_directory(self):
        """Инициализация папки для профилей"""
        # Проверяем, что атрибут существует и папка уже инициализирована
        if hasattr(self, 'profiles_dir') and self.profiles_dir and os.path.exists(self.profiles_dir):
            return  # Уже инициализирована
        
        try:
            # Определяем путь к папке профилей на основе пути к файлу mod_load_order.txt
            # Используем default_path для определения базовой директории
            mods_dir = os.path.dirname(self.default_path)
            if not mods_dir:
                raise ValueError("Не удалось определить директорию модов")
            
            self.profiles_dir = os.path.join(mods_dir, "ModLoadOrderManager_profiles")
            
            # Создаем папку, если её нет
            if not os.path.exists(self.profiles_dir):
                try:
                    os.makedirs(self.profiles_dir, exist_ok=True)
                except (PermissionError, OSError) as e:
                    # Если нет прав, используем папку рядом с программой
                    script_dir = os.path.dirname(os.path.abspath(__file__))
                    if script_dir:
                        self.profiles_dir = os.path.join(script_dir, "profiles")
                        os.makedirs(self.profiles_dir, exist_ok=True)
                    else:
                        raise
        except Exception as e:
            # Если не удалось создать в папке модов, используем папку рядом с программой
            try:
                script_dir = os.path.dirname(os.path.abspath(__file__))
                if script_dir:
                    self.profiles_dir = os.path.join(script_dir, "profiles")
                    os.makedirs(self.profiles_dir, exist_ok=True)
                else:
                    # Последняя попытка - текущая директория
                    self.profiles_dir = os.path.join(os.getcwd(), "profiles")
                    os.makedirs(self.profiles_dir, exist_ok=True)
            except Exception as e2:
                self.profiles_dir = None
                print(f"Не удалось создать папку для профилей: {e2}")
    
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
        
        # Сортировка
        ttk.Label(button_frame, text="Сортировка:", font=("Arial", 8)).pack(side=tk.LEFT, padx=(0, 2))
        self.sort_var = tk.StringVar(value="По порядку файла")
        sort_combo = ttk.Combobox(button_frame, textvariable=self.sort_var, width=15, state="readonly")
        sort_combo['values'] = ("По порядку файла", "По имени", "По статусу", "Новые сначала")
        sort_combo['state'] = 'readonly'
        sort_combo.bind("<<ComboboxSelected>>", self.on_sort_change)
        sort_combo.pack(side=tk.LEFT, padx=2)
        
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
        right_panel.configure(width=300)
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
        mod_info_label.pack(anchor=tk.W, fill=tk.X, pady=(0, 10))
        
        # Кнопки для ручной сортировки
        sort_buttons_frame = ttk.Frame(info_frame)
        sort_buttons_frame.pack(fill=tk.X, pady=(0, 10))
        
        ttk.Label(sort_buttons_frame, text="Порядок в файле:", font=("Arial", 9, "bold")).pack(anchor=tk.W, pady=(0, 5))
        
        buttons_row = ttk.Frame(sort_buttons_frame)
        buttons_row.pack(fill=tk.X)
        
        self.move_up_button = ttk.Button(buttons_row, text="↑ Вверх", command=self.move_mod_up, state=tk.DISABLED)
        self.move_up_button.pack(side=tk.LEFT, fill=tk.X, expand=True, padx=(0, 2))
        
        self.move_down_button = ttk.Button(buttons_row, text="↓ Вниз", command=self.move_mod_down, state=tk.DISABLED)
        self.move_down_button.pack(side=tk.LEFT, fill=tk.X, expand=True, padx=(2, 0))
        
        # Разделитель
        ttk.Separator(info_frame, orient=tk.HORIZONTAL).pack(fill=tk.X, pady=10)
        
        # Быстрое переключение
        quick_switch_frame = ttk.Frame(info_frame)
        quick_switch_frame.pack(fill=tk.X, pady=(0, 10))
        
        ttk.Label(quick_switch_frame, text="Быстрое переключение:", font=("Arial", 9, "bold")).pack(anchor=tk.W, pady=(0, 5))
        
        self.only_this_mod_button = ttk.Button(quick_switch_frame, text="Только этот мод", command=self.enable_only_this_mod, state=tk.DISABLED)
        self.only_this_mod_button.pack(fill=tk.X, pady=(0, 2))
        
        self.restore_state_button = ttk.Button(quick_switch_frame, text="Вернуть все", command=self.restore_saved_state, state=tk.DISABLED)
        self.restore_state_button.pack(fill=tk.X)
        
        # Разделитель
        ttk.Separator(info_frame, orient=tk.HORIZONTAL).pack(fill=tk.X, pady=10)
        
        # Профили
        profiles_frame = ttk.Frame(info_frame)
        profiles_frame.pack(fill=tk.BOTH, expand=True)
        
        ttk.Label(profiles_frame, text="Профили:", font=("Arial", 9, "bold")).pack(anchor=tk.W, pady=(0, 5))
        
        # Список профилей
        profiles_list_frame = ttk.Frame(profiles_frame)
        profiles_list_frame.pack(fill=tk.BOTH, expand=True)
        
        self.profiles_listbox = tk.Listbox(profiles_list_frame, height=4, font=("Arial", 8))
        self.profiles_listbox.pack(fill=tk.BOTH, expand=True, pady=(0, 5))
        self.profiles_listbox.bind("<<ListboxSelect>>", self.on_profile_select)
        
        # Кнопки управления профилями
        profile_buttons_frame = ttk.Frame(profiles_frame)
        profile_buttons_frame.pack(fill=tk.X)
        
        # Первая строка кнопок
        buttons_row1 = ttk.Frame(profile_buttons_frame)
        buttons_row1.pack(fill=tk.X, pady=(0, 2))
        
        ttk.Button(buttons_row1, text="Сохранить", command=self.save_current_profile).pack(side=tk.LEFT, fill=tk.X, expand=True, padx=(0, 2))
        ttk.Button(buttons_row1, text="Загрузить", command=self.load_selected_profile).pack(side=tk.LEFT, fill=tk.X, expand=True, padx=2)
        
        # Вторая строка кнопок
        buttons_row2 = ttk.Frame(profile_buttons_frame)
        buttons_row2.pack(fill=tk.X)
        
        ttk.Button(buttons_row2, text="Переименовать", command=self.rename_selected_profile).pack(side=tk.LEFT, fill=tk.X, expand=True, padx=(0, 2))
        ttk.Button(buttons_row2, text="Удалить", command=self.delete_selected_profile).pack(side=tk.LEFT, fill=tk.X, expand=True, padx=(2, 0))
        
        # Обновляем список профилей
        self.refresh_profiles_list()
        
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
                mod_index = len(self.mod_entries)  # Порядковый номер мода в файле
                if stripped.startswith("--"):
                    # Закомментированный мод (начинается с --, но без пробела или с именем мода)
                    mod_name = stripped[2:].strip()
                    # Проверяем, что это действительно имя мода (содержит буквы/цифры)
                    if mod_name and any(c.isalnum() for c in mod_name):
                        self.mod_entries.append(ModEntry(mod_name, False, stripped, order_index=mod_index))
                else:
                    # Активный мод (не начинается с --)
                    mod_name = stripped.strip()
                    if mod_name:  # Проверяем, что строка не пустая
                        self.mod_entries.append(ModEntry(mod_name, True, stripped, order_index=mod_index))
            
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
            # Новые моды получают большой order_index, чтобы быть в конце при сортировке по умолчанию
            base_index = len(self.mod_entries) + 1000  # Большой индекс для новых модов
            for idx, mod_name in enumerate(sorted(new_mods)):
                self.mod_entries.append(ModEntry(
                    name=mod_name,
                    enabled=False,  # Новые моды по умолчанию выключены
                    original_line=f"--{mod_name}",  # По умолчанию закомментированы
                    is_new=True,
                    order_index=base_index + idx  # Порядок для новых модов
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
            filtered = [
                mod for mod in self.mod_entries 
                if filter_lower in mod.name.lower()
            ]
        else:
            filtered = self.mod_entries.copy()
        
        # Сортировка модов
        self.filtered_mod_entries = self.sort_mods(filtered)
        
        # Получаем цвет фона для фреймов (используем тот же, что и для canvas)
        style = ttk.Style()
        frame_bg_color = style.lookup("TFrame", "background")
        if not frame_bg_color:
            frame_bg_color = "SystemButtonFace"
        
        # Создание чекбоксов для каждого мода
        self.checkbox_vars = {}
        for i, mod_entry in enumerate(self.filtered_mod_entries):
            var = tk.BooleanVar(value=mod_entry.enabled)
            self.checkbox_vars[mod_entry.name] = var
            
            # Используем обычный Frame вместо ttk для лучшего контроля выделения
            frame = tk.Frame(self.scrollable_frame, bg=frame_bg_color)
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
            mod_entry.frame = frame  # Сохраняем ссылку на фрейм для выделения
            
            # Выделение выбранного мода
            self.update_frame_highlight(frame, mod_entry.name == self.selected_mod_name)
        
        # Обновление статистики
        self.update_statistics()
    
    def sort_mods(self, mods: List[ModEntry]) -> List[ModEntry]:
        """Сортировка списка модов по выбранному критерию"""
        sort_type = self.sort_var.get() if hasattr(self, 'sort_var') else "По порядку файла"
        
        if sort_type == "По порядку файла":
            # Сортировка в порядке из файла (по order_index)
            return sorted(mods, key=lambda m: m.order_index)
        elif sort_type == "По имени":
            # Сортировка по имени (алфавитно)
            return sorted(mods, key=lambda m: m.name.lower())
        elif sort_type == "По статусу":
            # Сортировка по статусу: сначала включенные, потом выключенные
            return sorted(mods, key=lambda m: (not m.enabled, m.name.lower()))
        elif sort_type == "Новые сначала":
            # Сортировка: сначала новые моды, потом остальные (по имени)
            return sorted(mods, key=lambda m: (not m.is_new, m.name.lower()))
        else:
            # По умолчанию - в порядке из файла (по order_index)
            return sorted(mods, key=lambda m: m.order_index)
    
    def on_sort_change(self, event=None):
        """Обработка изменения типа сортировки"""
        search_text = self.search_var.get() if hasattr(self, 'search_var') else ""
        self.update_mod_list(filter_text=search_text)
        # Обновляем состояние кнопок перемещения
        self.update_move_buttons_state()
    
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
        # Снимаем выделение с предыдущего мода
        if self.selected_mod_name:
            prev_mod = next((m for m in self.mod_entries if m.name == self.selected_mod_name), None)
            if prev_mod and hasattr(prev_mod, 'frame'):
                self.update_frame_highlight(prev_mod.frame, False)
        
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
            
            # Выделяем выбранный мод
            if hasattr(mod_entry, 'frame'):
                self.update_frame_highlight(mod_entry.frame, True)
            
            status = "Включен" if actual_enabled else "Выключен"
            info_text = f"{mod_name}\nСтатус: {status}"
            if mod_entry.is_new:
                info_text += "\n⚠ Новый мод (не был в файле)"
            self.selected_mod_var.set(info_text)
            
            # Обновляем состояние кнопок перемещения
            self.update_move_buttons_state()
            # Обновляем состояние кнопки "Только этот мод"
            self.update_quick_switch_buttons()
        else:
            self.selected_mod_var.set("Нет выбора")
            # Отключаем кнопки, если мод не выбран
            if hasattr(self, 'move_up_button'):
                self.move_up_button.configure(state=tk.DISABLED)
            if hasattr(self, 'move_down_button'):
                self.move_down_button.configure(state=tk.DISABLED)
            if hasattr(self, 'only_this_mod_button'):
                self.only_this_mod_button.configure(state=tk.DISABLED)
    
    def update_frame_highlight(self, frame, is_selected):
        """Обновление визуального выделения фрейма мода"""
        # Получаем цвет фона по умолчанию
        style = ttk.Style()
        default_bg = style.lookup("TFrame", "background")
        if not default_bg:
            default_bg = "SystemButtonFace"
        
        if is_selected:
            # Выделение: рамка и цвет фона
            frame.configure(
                relief=tk.SOLID, 
                borderwidth=2, 
                highlightbackground="#2196F3",  # Синяя рамка
                highlightthickness=2,
                bg="#E3F2FD"  # Светло-синий фон
            )
        else:
            # Снимаем выделение
            frame.configure(
                relief=tk.FLAT, 
                borderwidth=0, 
                highlightthickness=0, 
                bg=default_bg
            )
    
    def update_statistics(self):
        """Обновление статистики в правой панели"""
        total = len(self.mod_entries)
        enabled = sum(1 for m in self.mod_entries if m.enabled)
        disabled = total - enabled
        
        self.stats_total_var.set(f"Всего модов: {total}")
        self.stats_enabled_var.set(f"Включено: {enabled}")
        self.stats_disabled_var.set(f"Выключено: {disabled}")
    
    def update_move_buttons_state(self):
        """Обновление состояния кнопок перемещения мода"""
        # Проверяем, активна ли сортировка "По порядку файла"
        current_sort = self.sort_var.get() if hasattr(self, 'sort_var') else "По порядку файла"
        
        if not self.selected_mod_name or current_sort != "По порядку файла":
            # Отключаем кнопки, если мод не выбран или выбрана другая сортировка
            if hasattr(self, 'move_up_button'):
                self.move_up_button.configure(state=tk.DISABLED)
            if hasattr(self, 'move_down_button'):
                self.move_down_button.configure(state=tk.DISABLED)
            return
        
        # Для ручной сортировки работаем с исходным порядком (order_index)
        # Сортируем по order_index для определения позиции
        sorted_mods = sorted(self.mod_entries, key=lambda m: m.order_index)
        mod_index = next((i for i, m in enumerate(sorted_mods) if m.name == self.selected_mod_name), -1)
        
        if mod_index == -1:
            # Мод не найден
            if hasattr(self, 'move_up_button'):
                self.move_up_button.configure(state=tk.DISABLED)
            if hasattr(self, 'move_down_button'):
                self.move_down_button.configure(state=tk.DISABLED)
            return
        
        # Включаем/отключаем кнопки в зависимости от позиции
        if hasattr(self, 'move_up_button'):
            self.move_up_button.configure(state=tk.NORMAL if mod_index > 0 else tk.DISABLED)
        if hasattr(self, 'move_down_button'):
            self.move_down_button.configure(state=tk.NORMAL if mod_index < len(sorted_mods) - 1 else tk.DISABLED)
    
    def move_mod_up(self):
        """Перемещение выбранного мода вверх в списке"""
        if not self.selected_mod_name:
            return
        
        # Находим мод в списке
        mod_entry = next((m for m in self.mod_entries if m.name == self.selected_mod_name), None)
        if not mod_entry:
            return
        
        # Сортируем по order_index для определения позиции
        sorted_mods = sorted(self.mod_entries, key=lambda m: m.order_index)
        current_index = next((i for i, m in enumerate(sorted_mods) if m.name == self.selected_mod_name), -1)
        
        if current_index <= 0:
            return  # Уже вверху
        
        # Меняем местами order_index с предыдущим модом
        prev_mod = sorted_mods[current_index - 1]
        mod_entry.order_index, prev_mod.order_index = prev_mod.order_index, mod_entry.order_index
        
        # Обновляем список с учетом новой сортировки
        search_text = self.search_var.get() if hasattr(self, 'search_var') else ""
        self.update_mod_list(filter_text=search_text)
        
        # Обновляем состояние кнопок
        self.update_move_buttons_state()
    
    def move_mod_down(self):
        """Перемещение выбранного мода вниз в списке"""
        if not self.selected_mod_name:
            return
        
        # Находим мод в списке
        mod_entry = next((m for m in self.mod_entries if m.name == self.selected_mod_name), None)
        if not mod_entry:
            return
        
        # Сортируем по order_index для определения позиции
        sorted_mods = sorted(self.mod_entries, key=lambda m: m.order_index)
        current_index = next((i for i, m in enumerate(sorted_mods) if m.name == self.selected_mod_name), -1)
        
        if current_index < 0 or current_index >= len(sorted_mods) - 1:
            return  # Уже внизу
        
        # Меняем местами order_index со следующим модом
        next_mod = sorted_mods[current_index + 1]
        mod_entry.order_index, next_mod.order_index = next_mod.order_index, mod_entry.order_index
        
        # Обновляем список с учетом новой сортировки
        search_text = self.search_var.get() if hasattr(self, 'search_var') else ""
        self.update_mod_list(filter_text=search_text)
        
        # Обновляем состояние кнопок
        self.update_move_buttons_state()
    
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
            
            # Сортируем моды по order_index перед сохранением
            sorted_mods = sorted(self.mod_entries, key=lambda m: m.order_index)
            
            # Добавляем моды в порядке из order_index
            for mod_entry in sorted_mods:
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
    
    def save_current_state(self) -> Dict:
        """Сохранение текущего состояния всех модов"""
        state = {}
        for mod_entry in self.mod_entries:
            # Получаем актуальное состояние из чекбоксов
            if hasattr(self, 'checkbox_vars') and mod_entry.name in self.checkbox_vars:
                enabled = self.checkbox_vars[mod_entry.name].get()
            else:
                enabled = mod_entry.enabled
            state[mod_entry.name] = enabled
        return state
    
    def restore_state(self, state: Dict):
        """Восстановление состояния модов из словаря"""
        if not state:
            return
        
        for mod_entry in self.mod_entries:
            if mod_entry.name in state:
                mod_entry.enabled = state[mod_entry.name]
                # Обновляем чекбоксы
                if hasattr(self, 'checkbox_vars') and mod_entry.name in self.checkbox_vars:
                    self.checkbox_vars[mod_entry.name].set(state[mod_entry.name])
        
        # Обновляем интерфейс
        search_text = self.search_var.get() if hasattr(self, 'search_var') else ""
        self.update_mod_list(filter_text=search_text)
        self.update_statistics()
    
    def enable_only_this_mod(self):
        """Включить только выбранный мод, сохранив текущее состояние"""
        if not self.selected_mod_name:
            return
        
        # Сохраняем текущее состояние
        self.saved_state = self.save_current_state()
        
        # Отключаем все моды
        for mod_entry in self.mod_entries:
            mod_entry.enabled = False
            if hasattr(self, 'checkbox_vars') and mod_entry.name in self.checkbox_vars:
                self.checkbox_vars[mod_entry.name].set(False)
        
        # Включаем только выбранный мод
        mod_entry = next((m for m in self.mod_entries if m.name == self.selected_mod_name), None)
        if mod_entry:
            mod_entry.enabled = True
            if hasattr(self, 'checkbox_vars') and mod_entry.name in self.checkbox_vars:
                self.checkbox_vars[mod_entry.name].set(True)
        
        # Обновляем интерфейс
        search_text = self.search_var.get() if hasattr(self, 'search_var') else ""
        self.update_mod_list(filter_text=search_text)
        self.update_statistics()
        
        # Обновляем состояние кнопок
        self.update_quick_switch_buttons()
        
        messagebox.showinfo("Готово", f"Включен только мод: {self.selected_mod_name}\nИспользуйте 'Вернуть все' для восстановления.")
    
    def restore_saved_state(self):
        """Восстановление сохраненного состояния"""
        if not self.saved_state:
            messagebox.showwarning("Предупреждение", "Нет сохраненного состояния для восстановления")
            return
        
        self.restore_state(self.saved_state)
        self.saved_state = None
        
        # Обновляем состояние кнопок
        self.update_quick_switch_buttons()
        
        messagebox.showinfo("Готово", "Состояние модов восстановлено")
    
    def update_quick_switch_buttons(self):
        """Обновление состояния кнопок быстрого переключения"""
        if hasattr(self, 'only_this_mod_button'):
            self.only_this_mod_button.configure(state=tk.NORMAL if self.selected_mod_name else tk.DISABLED)
        
        if hasattr(self, 'restore_state_button'):
            self.restore_state_button.configure(state=tk.NORMAL if self.saved_state else tk.DISABLED)
    
    def refresh_profiles_list(self):
        """Обновление списка профилей"""
        if not hasattr(self, 'profiles_listbox'):
            return
        
        # Проверяем и инициализируем папку профилей, если нужно
        if not self.profiles_dir:
            self.init_profiles_directory()
        
        self.profiles_listbox.delete(0, tk.END)
        
        if not self.profiles_dir:
            return
        
        try:
            if os.path.exists(self.profiles_dir):
                for filename in os.listdir(self.profiles_dir):
                    if filename.endswith('.json'):
                        profile_name = filename[:-5]  # Убираем .json
                        self.profiles_listbox.insert(tk.END, profile_name)
        except Exception as e:
            pass
    
    def save_current_profile(self):
        """Сохранение текущего состояния как профиля"""
        # Проверяем и инициализируем папку профилей, если нужно
        if not self.profiles_dir:
            self.init_profiles_directory()
        
        if not self.profiles_dir:
            messagebox.showerror("Ошибка", "Не удалось определить папку для профилей")
            return
        
        profile_name = simpledialog.askstring("Сохранить профиль", "Введите имя профиля:")
        if not profile_name:
            return
        
        # Очищаем имя от недопустимых символов
        profile_name = "".join(c for c in profile_name if c.isalnum() or c in (' ', '-', '_')).strip()
        if not profile_name:
            messagebox.showerror("Ошибка", "Недопустимое имя профиля")
            return
        
        try:
            state = self.save_current_state()
            profile_path = os.path.join(self.profiles_dir, f"{profile_name}.json")
            
            # Убеждаемся, что папка существует
            if not os.path.exists(self.profiles_dir):
                os.makedirs(self.profiles_dir)
            
            with open(profile_path, 'w', encoding='utf-8') as f:
                json.dump(state, f, indent=2, ensure_ascii=False)
            
            self.refresh_profiles_list()
            messagebox.showinfo("Успех", f"Профиль '{profile_name}' сохранен")
        except Exception as e:
            messagebox.showerror("Ошибка", f"Не удалось сохранить профиль:\n{str(e)}")
    
    def load_selected_profile(self):
        """Загрузка выбранного профиля"""
        # Проверяем и инициализируем папку профилей, если нужно
        if not self.profiles_dir:
            self.init_profiles_directory()
        
        if not self.profiles_dir:
            messagebox.showerror("Ошибка", "Не удалось определить папку для профилей")
            return
        
        selection = self.profiles_listbox.curselection()
        if not selection:
            messagebox.showwarning("Предупреждение", "Выберите профиль из списка")
            return
        
        profile_name = self.profiles_listbox.get(selection[0])
        profile_path = os.path.join(self.profiles_dir, f"{profile_name}.json")
        
        try:
            with open(profile_path, 'r', encoding='utf-8') as f:
                state = json.load(f)
            
            self.restore_state(state)
            messagebox.showinfo("Успех", f"Профиль '{profile_name}' загружен")
        except Exception as e:
            messagebox.showerror("Ошибка", f"Не удалось загрузить профиль:\n{str(e)}")
    
    def rename_selected_profile(self):
        """Переименование выбранного профиля"""
        # Проверяем и инициализируем папку профилей, если нужно
        if not self.profiles_dir:
            self.init_profiles_directory()
        
        if not self.profiles_dir:
            messagebox.showerror("Ошибка", "Не удалось определить папку для профилей")
            return
        
        selection = self.profiles_listbox.curselection()
        if not selection:
            messagebox.showwarning("Предупреждение", "Выберите профиль из списка")
            return
        
        old_profile_name = self.profiles_listbox.get(selection[0])
        
        # Запрашиваем новое имя
        new_profile_name = simpledialog.askstring("Переименовать профиль", f"Введите новое имя для профиля '{old_profile_name}':", initialvalue=old_profile_name)
        if not new_profile_name:
            return
        
        # Очищаем имя от недопустимых символов
        new_profile_name = "".join(c for c in new_profile_name if c.isalnum() or c in (' ', '-', '_')).strip()
        if not new_profile_name:
            messagebox.showerror("Ошибка", "Недопустимое имя профиля")
            return
        
        # Проверяем, что новое имя отличается от старого
        if new_profile_name == old_profile_name:
            return
        
        # Проверяем, что профиль с таким именем не существует
        new_profile_path = os.path.join(self.profiles_dir, f"{new_profile_name}.json")
        if os.path.exists(new_profile_path):
            messagebox.showerror("Ошибка", f"Профиль с именем '{new_profile_name}' уже существует")
            return
        
        try:
            old_profile_path = os.path.join(self.profiles_dir, f"{old_profile_name}.json")
            if os.path.exists(old_profile_path):
                # Переименовываем файл
                os.rename(old_profile_path, new_profile_path)
                self.refresh_profiles_list()
                messagebox.showinfo("Успех", f"Профиль '{old_profile_name}' переименован в '{new_profile_name}'")
            else:
                messagebox.showerror("Ошибка", f"Файл профиля '{old_profile_name}' не найден")
        except Exception as e:
            messagebox.showerror("Ошибка", f"Не удалось переименовать профиль:\n{str(e)}")
    
    def delete_selected_profile(self):
        """Удаление выбранного профиля"""
        # Проверяем и инициализируем папку профилей, если нужно
        if not self.profiles_dir:
            self.init_profiles_directory()
        
        if not self.profiles_dir:
            messagebox.showerror("Ошибка", "Не удалось определить папку для профилей")
            return
        
        selection = self.profiles_listbox.curselection()
        if not selection:
            messagebox.showwarning("Предупреждение", "Выберите профиль из списка")
            return
        
        profile_name = self.profiles_listbox.get(selection[0])
        
        if not messagebox.askyesno("Подтверждение", f"Удалить профиль '{profile_name}'?"):
            return
        
        try:
            profile_path = os.path.join(self.profiles_dir, f"{profile_name}.json")
            if os.path.exists(profile_path):
                os.remove(profile_path)
                self.refresh_profiles_list()
                messagebox.showinfo("Успех", f"Профиль '{profile_name}' удален")
        except Exception as e:
            messagebox.showerror("Ошибка", f"Не удалось удалить профиль:\n{str(e)}")
    
    def on_profile_select(self, event=None):
        """Обработка выбора профиля в списке"""
        pass  # Можно добавить предпросмотр профиля


def main():
    """Точка входа в приложение"""
    root = tk.Tk()
    app = ModLoadOrderManager(root)
    root.mainloop()


if __name__ == "__main__":
    main()
