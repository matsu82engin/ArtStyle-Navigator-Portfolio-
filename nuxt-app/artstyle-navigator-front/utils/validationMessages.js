export function translateErrorMessages(messages) {

  const dictionary = {
    // User
    "Name can't be blank": "名前を入力してください",
    "Name is too long (maximum is 50 characters)": "名前は50文字以内で入力してください",
    "Email can't be blank": "メールアドレスを入力してください",
    "Email is invalid": "メールアドレスの形式が正しくありません",
    "Email is not an email": "メールの形式が正しくありません。",
    "Email is too long (maximum is 255 characters)": "メールアドレスは255文字以内で入力してください",
    "Email has already been taken": "そのメールアドレスはすでに登録されています",
    "Password can't be blank": "パスワードを入力してください",
    "Password is too short (minimum is 6 characters)": "パスワードは6文字以上で入力してください",
    "Password confirmation can't be blank": "パスワード確認を入力してください",
    "Password confirmation doesn't match Password": "パスワード確認が一致しません",
    "Current password can't be blank": "現在のパスワードは空白にできません",
    "Current password is invalid": "現在のパスワードが正しくありません",
    // ↓これは日本語だが、これがないとフォームの入力内容にエラーがありますが表示されてしまう
    "現在のパスワードが正しくありません": "現在のパスワードが正しくありません",

    // Profile
    "User has already been taken": "プロフィールはすでに存在します",
    "Pen name can't be blank": "ペンネームは空欄にできません",
    "Pen name is too long (maximum is 20 characters)": "ペンネームは20文字以内で入力してください",
    "Introduction is too long (maximum is 500 characters)": "自己紹介は500文字以内で入力してください",
    // 必要に応じて追加...
  }

  // 一つも翻訳されなかった場合(不明な形のエラーに対応)
  const translated = messages.map(msg => dictionary[msg])
  if (translated.every(msg => msg === undefined)) {
    return ['フォームの入力内容にエラーがあります。']
  }

  // 翻訳できなかったメッセージは英語のまま表示
  return messages.map(msg => dictionary[msg] || msg)
}
