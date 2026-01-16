// Менеджер модальных окон
export class ModalManager {
    constructor(elements) {
        this.elements = elements;
        this.modalCallback = null;
        this.init();
    }
    
    init() {
        // Привязка событий модального окна
        this.elements.modalOkBtn.addEventListener('click', () => this.handleModalOk());
        this.elements.modalCancelBtn.addEventListener('click', () => this.handleModalCancel());
        
        // Обработчик keydown для поля ввода
        this.elements.profileNameInput.addEventListener('keydown', (e) => {
            if (e.key === 'Enter') {
                e.preventDefault();
                this.handleModalOk();
            } else if (e.key === 'Escape') {
                e.preventDefault();
                this.handleModalCancel();
            }
        });
        
        // Убираем закрытие по клику на фон - только через кнопки
    }
    
    showModal(title, defaultValue = '', callback) {
        this.elements.modalTitle.textContent = title;
        this.elements.profileNameInput.value = defaultValue || '';
        this.modalCallback = callback;
        this.elements.profileDialog.classList.add('show');
    }
    
    hideModal() {
        this.elements.profileDialog.classList.remove('show');
        this.elements.profileNameInput.value = '';
        this.modalCallback = null;
    }
    
    handleModalOk() {
        const value = this.elements.profileNameInput.value.trim();
        const callback = this.modalCallback;
        this.hideModal();
        if (callback) {
            callback(value);
        }
    }
    
    handleModalCancel() {
        const callback = this.modalCallback;
        this.hideModal();
        if (callback) {
            callback(null);
        }
    }
}
