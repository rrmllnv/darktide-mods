#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import re

# Читаем файл color.lua
with open('color.lua', 'r', encoding='utf-8') as f:
    content = f.read()

# Парсим цвета из таблицы color_definitions
# Формат: color_name = { alpha, red, green, blue, }
pattern = r'^\s+(\w+)\s*=\s*\{[\s\n]*(\d+),[\s\n]*(\d+),[\s\n]*(\d+),[\s\n]*(\d+),[\s\n]*\},'
colors = re.findall(pattern, content, re.MULTILINE)

# Сортируем цвета по имени
colors.sort(key=lambda x: x[0])

# Генерируем HTML
html = '''<!DOCTYPE html>
<html lang="ru">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Darktide Colors - Все цвета из color.lua</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: #1a1a1a;
            color: #e0e0e0;
            padding: 20px;
        }
        .container {
            max-width: 1400px;
            margin: 0 auto;
        }
        h1 {
            color: #fff;
            margin-bottom: 30px;
            text-align: center;
            font-size: 2.5em;
        }
        .stats {
            text-align: center;
            margin-bottom: 30px;
            color: #aaa;
            font-size: 1.1em;
        }
        .search-box {
            width: 100%;
            max-width: 500px;
            margin: 0 auto 30px;
            padding: 12px 20px;
            font-size: 16px;
            background: #2a2a2a;
            border: 2px solid #444;
            border-radius: 8px;
            color: #e0e0e0;
            outline: none;
        }
        .search-box:focus {
            border-color: #6b9;
        }
        .search-box::placeholder {
            color: #888;
        }
        table {
            width: 100%;
            border-collapse: collapse;
            background: #222;
            border-radius: 8px;
            overflow: hidden;
            box-shadow: 0 4px 6px rgba(0, 0, 0, 0.3);
        }
        thead {
            background: #333;
            position: sticky;
            top: 0;
            z-index: 10;
        }
        th {
            padding: 15px;
            text-align: left;
            font-weight: 600;
            color: #fff;
            border-bottom: 2px solid #444;
        }
        th:nth-child(1) { width: 25%; }
        th:nth-child(2) { width: 15%; }
        th:nth-child(3) { width: 20%; }
        th:nth-child(4) { width: 40%; }
        tbody tr {
            border-bottom: 1px solid #333;
            transition: background 0.2s;
        }
        tbody tr:hover {
            background: #2a2a2a;
        }
        tbody tr.hidden {
            display: none;
        }
        td {
            padding: 12px 15px;
            vertical-align: middle;
        }
        .color-name {
            font-family: 'Consolas', 'Monaco', monospace;
            color: #6b9;
            font-weight: 500;
        }
        .color-code {
            font-family: 'Consolas', 'Monaco', monospace;
            color: #9bb;
            font-size: 0.9em;
        }
        .color-preview {
            display: flex;
            align-items: center;
            gap: 10px;
        }
        .color-square {
            width: 60px;
            height: 60px;
            border-radius: 6px;
            border: 2px solid #444;
            flex-shrink: 0;
            box-shadow: 0 2px 4px rgba(0, 0, 0, 0.3);
        }
        .color-bar {
            flex: 1;
            height: 30px;
            border-radius: 4px;
            border: 1px solid #444;
            box-shadow: 0 2px 4px rgba(0, 0, 0, 0.3);
        }
        .no-results {
            text-align: center;
            padding: 40px;
            color: #888;
            display: none;
        }
        .no-results.show {
            display: block;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>🎨 Darktide Colors</h1>
        <div class="stats">Всего цветов: <strong id="total-count">''' + str(len(colors)) + '''</strong> | Показано: <strong id="visible-count">''' + str(len(colors)) + '''</strong></div>
        <input type="text" class="search-box" id="search" placeholder="🔍 Поиск по названию цвета...">
        <div class="no-results" id="no-results">Ничего не найдено</div>
        <table>
            <thead>
                <tr>
                    <th>Название цвета</th>
                    <th>Код (RGBA)</th>
                    <th>Квадрат</th>
                    <th>Полоска</th>
                </tr>
            </thead>
            <tbody id="color-table">
'''

# Добавляем строки таблицы
for name, alpha, red, green, blue in colors:
    # Конвертируем в hex для CSS
    rgba_css = f'rgba({red}, {green}, {blue}, {int(alpha)/255:.2f})'
    rgba_code = f'{alpha}, {red}, {green}, {blue}'
    
    html += f'''                <tr data-name="{name.lower()}">
                    <td class="color-name">{name}</td>
                    <td class="color-code">{rgba_code}</td>
                    <td>
                        <div class="color-preview">
                            <div class="color-square" style="background-color: {rgba_css};"></div>
                        </div>
                    </td>
                    <td>
                        <div class="color-bar" style="background-color: {rgba_css};"></div>
                    </td>
                </tr>
'''

html += '''            </tbody>
        </table>
    </div>
    <script>
        const searchBox = document.getElementById('search');
        const table = document.getElementById('color-table');
        const rows = table.querySelectorAll('tr');
        const totalCount = document.getElementById('total-count');
        const visibleCount = document.getElementById('visible-count');
        const noResults = document.getElementById('no-results');
        
        function updateCounts() {
            const visible = Array.from(rows).filter(r => !r.classList.contains('hidden')).length;
            visibleCount.textContent = visible;
            
            if (visible === 0) {
                noResults.classList.add('show');
            } else {
                noResults.classList.remove('show');
            }
        }
        
        searchBox.addEventListener('input', function(e) {
            const searchTerm = e.target.value.toLowerCase().trim();
            
            rows.forEach(row => {
                const name = row.getAttribute('data-name');
                if (name.includes(searchTerm)) {
                    row.classList.remove('hidden');
                } else {
                    row.classList.add('hidden');
                }
            });
            
            updateCounts();
        });
        
        // Инициализация счетчика
        updateCounts();
    </script>
</body>
</html>
'''

# Сохраняем HTML файл
with open('colors.html', 'w', encoding='utf-8') as f:
    f.write(html)

print(f'Success: Created colors.html with {len(colors)} colors')
