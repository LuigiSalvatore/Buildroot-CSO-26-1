#include <stdio.h>

int main() {
    FILE *f = fopen("/var/www/index.html", "w");

    fprintf(f, "<html><body>");
    fprintf(f, "<h1>Monitor do Sistema</h1>");

    FILE *proc = fopen("/proc/version", "r");
    char buffer[256];

    if (proc) {
        fgets(buffer, sizeof(buffer), proc);
        fprintf(f, "<p><b>Kernel:</b> %s</p>", buffer);
        fclose(proc);
    }

    fprintf(f, "</body></html>");
    fclose(f);

    return 0;
}
