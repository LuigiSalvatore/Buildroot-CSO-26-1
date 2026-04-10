#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>

void get_uptime() {
    FILE *f = fopen("/proc/uptime", "r");
    if (!f) return;

    double uptime, idle;
    fscanf(f, "%lf %lf", &uptime, &idle);
    fclose(f);

    int days = uptime / 86400;
    int hours = ((int)uptime % 86400) / 3600;
    int minutes = ((int)uptime % 3600) / 60;
    int seconds = (int)uptime % 60;

    printf("<p>Uptime: %d d %d h %d m %d s</p>", days, hours, minutes, seconds);
}

void get_kernel() {
    FILE *f = fopen("/proc/version", "r");
    if (!f) return;

    char buffer[256];
    fgets(buffer, sizeof(buffer), f);
    fclose(f);

    printf("<p>Kernel: %s</p>", buffer);
}

void get_cpu() {
    FILE *f = fopen("/proc/cpuinfo", "r");
    if (!f) return;

    char line[256];
    while (fgets(line, sizeof(line), f)) {
        if (strstr(line, "model name")) {
            printf("<p>%s</p>", line);
            break;
        }
    }

    fclose(f);
}

void get_mem() {
    FILE *f = fopen("/proc/meminfo", "r");
    if (!f) return;

    char line[256];
    int count = 0;

    while (fgets(line, sizeof(line), f) && count < 2) {
        printf("<p>%s</p>", line);
        count++;
    }

    fclose(f);
}

void get_datetime() {
    time_t t = time(NULL);
    printf("<p>Data/Hora: %s</p>", ctime(&t));
}

int main(void) {
    printf("Content-Type: text/html\r\n\r\n");

    printf("<html><body>");
    printf("<h1>System Monitor</h1>");

    get_kernel();
    get_uptime();
    get_datetime();
    get_cpu();
    get_mem();

    printf("</body></html>");

    return 0;
}
