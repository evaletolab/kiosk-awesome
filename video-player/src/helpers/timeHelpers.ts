

export function formatTime(time: number): string{
    const minutes = Math.floor(time / 60);
    const seconds = time % 60;
    
    const minStr = minutes.toString().padStart(2, '0');
    const secondsStr = seconds.toString().padStart(2, '0');

    return `${minStr}:${secondsStr}`;
}