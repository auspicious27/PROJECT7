# MLOps Pipeline - Setup & Verification Checklist

Use this checklist to ensure your MLOps pipeline is properly set up and working.

## ✅ Pre-Installation Checklist

- [ ] Running Amazon Linux or RHEL
- [ ] Have root or sudo access
- [ ] At least 2 GB RAM available
- [ ] At least 10 GB disk space available
- [ ] Internet connection is working
- [ ] Downloaded/cloned the project

## ✅ Installation Checklist

- [ ] Made scripts executable: `chmod +x *.sh`
- [ ] Ran installation script: `./install.sh`
- [ ] Installation completed without errors
- [ ] Python 3 is installed: `python3 --version`
- [ ] pip is installed: `pip3 --version`
- [ ] Docker is installed: `docker --version`
- [ ] Docker Compose is installed: `docker-compose --version`
- [ ] Docker daemon is running: `docker ps`
- [ ] User added to docker group (if needed)
- [ ] Logged out and back in (if docker group was added)

## ✅ Verification Checklist

- [ ] Ran verification script: `./verify_setup.sh`
- [ ] All system dependencies show ✅
- [ ] All Python packages show ✅
- [ ] All project files exist
- [ ] No critical errors in verification

## ✅ Model Training Checklist

- [ ] Ran training script: `python3 app/train_model.py`
- [ ] Training completed successfully
- [ ] `app/models/model_v1.pkl` exists
- [ ] `app/models/model_v2.pkl` exists
- [ ] `app/models/training_stats.pkl` exists
- [ ] Both models show accuracy metrics

## ✅ Service Startup Checklist

- [ ] Ran demo script: `./run_demo.sh`
- [ ] Docker images built successfully
- [ ] All containers started
- [ ] No error messages in startup
- [ ] Ran `docker-compose ps` - all services show "Up"

## ✅ Service Access Checklist

- [ ] Can access Streamlit UI: http://localhost:8501
- [ ] Can access Flask API: http://localhost:5000
- [ ] Can access Prometheus: http://localhost:9090
- [ ] API health check works: `curl http://localhost:5000/health`
- [ ] API returns valid JSON response

## ✅ Functionality Checklist

### Streamlit UI
- [ ] UI loads without errors
- [ ] Can adjust feature sliders
- [ ] "Get Prediction" button works
- [ ] Prediction result displays
- [ ] Model version shows (v1 or v2)
- [ ] Statistics update after predictions
- [ ] No error messages in UI

### Flask API
- [ ] Health endpoint works: `GET /health`
- [ ] Config endpoint works: `GET /config`
- [ ] Predict endpoint works: `POST /predict`
- [ ] Returns valid predictions
- [ ] Returns model version
- [ ] Returns latency information
- [ ] Handles invalid input gracefully

### Prometheus
- [ ] Prometheus UI loads
- [ ] Can query metrics
- [ ] `prediction_requests_total` metric exists
- [ ] `model_version_requests_total` metric exists
- [ ] `prediction_latency_seconds` metric exists
- [ ] Metrics update after predictions

## ✅ Testing Checklist

- [ ] Ran API test script: `./test_api.sh`
- [ ] All API tests pass
- [ ] Load test completes
- [ ] A/B split shows ~50/50 distribution
- [ ] Ran unit tests: `python3 -m pytest tests/ -v`
- [ ] All unit tests pass
- [ ] Ran example script: `python3 example_usage.py`
- [ ] Examples complete successfully

## ✅ Monitoring Checklist

- [ ] Prometheus scrapes Flask metrics
- [ ] Can query `prediction_requests_total`
- [ ] Can query `model_version_requests_total{version="v1"}`
- [ ] Can query `model_version_requests_total{version="v2"}`
- [ ] Can query `prediction_latency_seconds`
- [ ] Metrics update in real-time
- [ ] Ran drift detection: `python3 app/monitoring.py`
- [ ] Drift detection completes without errors

## ✅ A/B Testing Checklist

- [ ] Default split is 50/50
- [ ] Can view config: `curl http://localhost:5000/config`
- [ ] Both models serve requests
- [ ] Model version tracked in responses
- [ ] Metrics show both model versions
- [ ] Can change weights in docker-compose.yml
- [ ] After restart, new weights take effect

## ✅ Documentation Checklist

- [ ] Read README.md
- [ ] Read GETTING_STARTED.md
- [ ] Reviewed QUICKSTART.md
- [ ] Understand basic architecture
- [ ] Know how to start/stop services
- [ ] Know how to view logs
- [ ] Know how to troubleshoot issues

## ✅ Advanced Features Checklist (Optional)

- [ ] Reviewed Jenkinsfile
- [ ] Understand CI/CD pipeline
- [ ] Reviewed Terraform configs
- [ ] Understand deployment options
- [ ] Can modify A/B split weights
- [ ] Can retrain models
- [ ] Can add custom metrics
- [ ] Can extend the code

## 🔧 Troubleshooting Checklist

If something doesn't work:

- [ ] Checked logs: `docker-compose logs`
- [ ] Verified services running: `docker-compose ps`
- [ ] Checked ports not in use: `netstat -tuln | grep -E '5000|8501|9090'`
- [ ] Restarted services: `docker-compose restart`
- [ ] Rebuilt containers: `docker-compose build --no-cache`
- [ ] Checked disk space: `df -h`
- [ ] Checked memory: `free -h`
- [ ] Reviewed error messages
- [ ] Consulted troubleshooting section in README.md

## 📊 Performance Checklist

- [ ] API responds in < 100ms
- [ ] UI loads in < 5 seconds
- [ ] Predictions complete quickly
- [ ] No memory leaks observed
- [ ] CPU usage is reasonable
- [ ] Containers are healthy
- [ ] No excessive logging

## 🔒 Security Checklist (Production)

For production deployment:

- [ ] Changed default configurations
- [ ] Added authentication to API
- [ ] Enabled HTTPS/TLS
- [ ] Restricted security group rules
- [ ] Using secrets management
- [ ] Enabled rate limiting
- [ ] Added input validation
- [ ] Enabled audit logging
- [ ] Regular security updates
- [ ] Monitoring for anomalies

## 📝 Maintenance Checklist

Regular maintenance tasks:

- [ ] Monitor disk space
- [ ] Monitor memory usage
- [ ] Check for drift regularly
- [ ] Review logs for errors
- [ ] Update dependencies
- [ ] Retrain models periodically
- [ ] Backup models
- [ ] Test disaster recovery
- [ ] Review metrics and alerts
- [ ] Update documentation

## ✨ Success Criteria

Your MLOps pipeline is fully working if:

- ✅ All services start without errors
- ✅ Can make predictions via UI
- ✅ Can make predictions via API
- ✅ A/B testing works (both models serve requests)
- ✅ Prometheus collects metrics
- ✅ All tests pass
- ✅ Drift detection runs
- ✅ Logs show no errors
- ✅ Performance is acceptable
- ✅ Documentation is clear

## 🎯 Next Steps After Completion

Once everything is checked:

1. [ ] Experiment with different A/B splits
2. [ ] Try different input values
3. [ ] Monitor metrics over time
4. [ ] Review the code
5. [ ] Customize for your needs
6. [ ] Add your own models
7. [ ] Extend the functionality
8. [ ] Deploy to production (if ready)
9. [ ] Share with your team
10. [ ] Provide feedback

## 📞 Getting Help

If you're stuck:

1. Run `./verify_setup.sh` to diagnose issues
2. Check `docker-compose logs` for errors
3. Review the troubleshooting section in README.md
4. Consult GETTING_STARTED.md
5. Check that all prerequisites are met

## 🎉 Completion

- [ ] All critical items checked
- [ ] System is fully functional
- [ ] Understand how to use the system
- [ ] Know how to troubleshoot
- [ ] Ready to customize/extend
- [ ] Ready for production (if applicable)

---

**Congratulations!** If all items are checked, your MLOps pipeline is ready to use! 🚀
