# Docker Optimization & Colima Setup for MacBook Pro 2015

## Why Consider Colima?
- **Lighter footprint**: Uses fewer resources than Docker Desktop
- **Better performance**: Direct integration with macOS
- **Free**: No licensing costs
- **Customizable**: Full control over resource allocation

---

## 1. Docker Desktop Resource Optimization

### Current Docker Desktop Settings (if keeping Docker Desktop):
```json
// In Docker Desktop → Settings → Resources
{
  "cpus": 2,
  "memory": 2048,
  "swap": 512,
  "disk": 64
}
```

### Regular Cleanup Commands:
```bash
# Remove unused containers, networks, images
docker system prune -a

# Remove specific unused resources
docker container prune
docker image prune
docker volume prune
docker network prune

# Check disk usage
docker system df
```

---

## 2. Colima Setup (Recommended Alternative)

### Install Colima:
```bash
brew install colima
```

### Start Colima with Resource Limits:
```bash
# Basic setup (2 CPU, 2GB RAM)
colima start --cpu 2 --memory 2048

# With disk space limit
colima start --cpu 2 --memory 2048 --disk 20

# With specific Kubernetes version (if needed)
colima start --kubernetes --kubernetes-version v1.24.0
```

### Colima Management:
```bash
# Check status
colima status

# Stop Colima
colima stop

# Delete Colima VM
colima delete

# List Colima instances
colima list
```

---

## 3. Migration Strategy

### Option A: Keep Docker Desktop (Optimized)
1. Apply resource limits in Docker Desktop settings
2. Set up regular cleanup scripts
3. Monitor resource usage

### Option B: Switch to Colima
1. Install Colima
2. Export Docker Desktop images: `docker save image > backup.tar`
3. Stop Docker Desktop
4. Start Colima with appropriate resources
5. Import images: `docker load < backup.tar`

### Option C: Hybrid Approach
- Use Colima for development
- Keep Docker Desktop for specific workflows

---

## 4. Resource Monitoring

### Check Docker Resource Usage:
```bash
# Docker Desktop
docker stats

# Colima
colima status
docker stats
```

### Monitor Disk Usage:
```bash
# Check Docker disk usage
docker system df

# Check Colima disk usage
colima status
```

---

## 5. Best Practices for MacBook Pro 2015

### Memory Management:
- Limit containers to 512MB-1GB each
- Use multi-stage builds to reduce image size
- Regular cleanup of unused images/volumes

### CPU Management:
- Limit to 1-2 cores per container
- Avoid running multiple heavy containers simultaneously

### Storage Management:
- Use `.dockerignore` files
- Regular cleanup of build cache
- Monitor disk space usage

---

## 6. Troubleshooting

### Common Issues:
- **High memory usage**: Reduce container memory limits
- **Slow performance**: Check for too many running containers
- **Disk space**: Regular cleanup of images and volumes

### Performance Tips:
- Restart Colima/Docker Desktop weekly
- Use lightweight base images (alpine, slim)
- Implement resource limits in docker-compose.yml 
## 📁 Contents

### **Files**
- `docker-optimize.sh` - [Description of purpose]

### **Subdirectories**
- No subdirectories found

## 🚀 Quick Start

```bash
# Example commands for this directory
# command1
# command2
```
