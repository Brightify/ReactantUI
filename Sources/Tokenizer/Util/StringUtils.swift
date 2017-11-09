extension String {
    public func capitalizingFirstLetter() -> String {
        let first = String(self[self.startIndex]).capitalized
        let other = String(self.dropFirst())
        return first + other
    }
}
