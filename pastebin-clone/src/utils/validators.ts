export function validatePasteContent(content: string): boolean {
    const minLength = 1;
    const maxLength = 10000; // Example max length for a paste
    return content.length >= minLength && content.length <= maxLength;
}

export function validateAuthKey(authKey: string): boolean {
    const expectedKey = process.env.AUTH_KEY; // Assuming the key is stored in environment variables
    return authKey === expectedKey;
}

export function validateUserInput(username: string, password: string): boolean {
    const usernameRegex = /^[a-zA-Z0-9]{3,20}$/; // Example username validation
    const passwordRegex = /^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{8,}$/; // Example password validation
    return usernameRegex.test(username) && passwordRegex.test(password);
}